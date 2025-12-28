import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/utils/helpers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  // Constantes pour les noms de fichiers
  static const String csvHeader =
      'Date,Heure,Titre,Description,Catégorie,Montant,Type,Lieu,Tags\n';

  Future<File> exportToCSV(
      List<Transaction> transactions, String fileName) async {
    try {
      final List<List<dynamic>> csvData = [];

      // En-tête
      csvData.add([
        'Date',
        'Heure',
        'Titre',
        'Description',
        'Catégorie',
        'Montant',
        'Type',
        'Lieu',
        'Tags'
      ]);

      for (var transaction in transactions) {
        csvData.add([
          Helpers.formatDate(transaction.date),
          Helpers.formatDate(transaction.date, format: 'HH:mm'),
          transaction.title,
          transaction.description,
          transaction.category,
          transaction.amount,
          transaction.isExpense ? 'Dépense' : 'Revenu',
          transaction.location ?? '',
          transaction.tags ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.csv');

      await file.writeAsString(csvString);
      return file;
    } catch (e) {
      debugPrint('Erreur export CSV: $e');
      rethrow;
    }
  }

  Future<File> exportToPDF(
    List<Transaction> transactions, {
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = pw.Document();

      pw.Font? font;
      try {
        final fontData =
            await rootBundle.load('assets/fonts/Inter-Regular.ttf');
        font = pw.Font.ttf(fontData);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Police non trouvée, utilisation de la police par défaut: $e');
        }
      }

      final expenseTransactions =
          transactions.where((t) => t.isExpense).toList();
      final incomeTransactions =
          transactions.where((t) => !t.isExpense).toList();

      final totalExpense =
          expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final totalIncome =
          incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final balance = totalIncome - totalExpense;

      // Calculer les totaux par catégorie
      final categoryTotals = <String, double>{};
      for (var transaction in expenseTransactions) {
        categoryTotals.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: font != null ? pw.ThemeData.withFont(base: font) : null,
          build: (pw.Context context) {
            return [
              // En-tête
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Période: ${Helpers.formatDate(startDate)} - ${Helpers.formatDate(endDate)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(),
                  ],
                ),
              ),

              // Résumé
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                        'Revenus', '\$${totalIncome.toStringAsFixed(2)}', true),
                    _buildStatCard('Dépenses',
                        '\$${totalExpense.toStringAsFixed(2)}', false),
                    _buildStatCard('Solde', '\$${balance.toStringAsFixed(2)}',
                        balance >= 0),
                  ],
                ),
              ),

              // Graphique des catégories
              if (categoryTotals.isNotEmpty)
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Dépenses par Catégorie',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      ...categoryTotals.entries.map((entry) {
                        final percentage = totalExpense > 0
                            ? (entry.value / totalExpense * 100)
                            : 0;
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(entry.key),
                                  pw.Text(
                                      '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)'),
                                ],
                              ),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                height: 6,
                                width: percentage * 2,
                                color: PdfColors.blue400,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              // Transactions détaillées
              if (transactions.isNotEmpty) ...[
                pw.Text(
                  'Transactions Détailées',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Table des transactions
                // ignore: deprecated_member_use
                pw.Table.fromTextArray(
                  context: context,
                  border: null,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  headers: ['Date', 'Description', 'Catégorie', 'Montant'],
                  data: transactions.map((transaction) {
                    return [
                      Helpers.formatDate(transaction.date),
                      transaction.title,
                      transaction.category,
                      '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                ),
              ],

              // Message si pas de transactions
              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text(
                      'Aucune transaction pour cette période',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                ),

              // Pied de page
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 30),
                child: pw.Column(
                  children: [
                    pw.Divider(),
                    pw.Text(
                      'Généré par Budget Manager • ${Helpers.formatDate(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${_sanitizeFileName(title)}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur export PDF: $e');
      }
      rethrow;
    }
  }

  pw.Widget _buildStatCard(String label, String value, bool isPositive) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: isPositive ? PdfColors.green : PdfColors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> shareFile(File file, String subject) async {
    try {
      // Fonctionnalité de partage désactivée - à implémenter selon vos besoins
      if (kDebugMode) {
        debugPrint('Partage du fichier: ${file.path}');
      }
      if (kDebugMode) {
        debugPrint('Sujet: $subject');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur partage fichier: $e');
      }
      rethrow;
    }
  }

  Future<String> exportToJson(List<Transaction> transactions) async {
    try {
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalTransactions': transactions.length,
        'transactions': transactions.map((t) {
          return {
            'id': t.id,
            'title': t.title,
            'description': t.description,
            'amount': t.amount,
            'category': t.category,
            'date': t.date.toIso8601String(),
            'isExpense': t.isExpense,
            'location': t.location,
            'tags': t.tags,
          };
        }).toList(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.json');

      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur export JSON: $e');
      }
      rethrow;
    }
  }

  Future<File> generateMonthlyReport({
    required List<Transaction> transactions,
    required DateTime month,
    required Map<String, double> categoryBudgets,
  }) async {
    final monthName = Helpers.formatDate(month, format: 'MMMM yyyy');

    return await exportToPDF(
      transactions,
      title: 'Rapport Mensuel - $monthName',
      startDate: DateTime(month.year, month.month, 1),
      endDate: DateTime(month.year, month.month + 1, 0),
    );
  }

  Future<String> uploadToCloudStorage(File file, String userId) async {
    try {
      final storage = FirebaseStorage.instance;
      final fileName = 'exports/$userId/${file.path.split('/').last}';

      final ref = storage.ref().child(fileName);
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur upload cloud storage: $e');
      }
      rethrow;
    }
  }

  Future<List<File>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);

      if (!await dir.exists()) {
        return [];
      }

      final files = await dir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) =>
              file.path.endsWith('.pdf') ||
              file.path.endsWith('.csv') ||
              file.path.endsWith('.json'))
          .toList();

      // Trier par date de modification (plus récent d'abord)
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      return files;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur récupération fichiers: $e');
      }
      return [];
    }
  }

  Future<bool> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur suppression fichier: $e');
      }
      return false;
    }
  }

  String _sanitizeFileName(String fileName) {
    // Supprimer les caractères invalides pour les noms de fichiers
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, fileName.length < 100 ? fileName.length : 100);
  }

  Future<void> exportAllFormats(
      List<Transaction> transactions, String baseName) async {
    try {
      // Exporter en CSV
      final csvFile = await exportToCSV(transactions, baseName);

      // Exporter en PDF
      final pdfFile = await exportToPDF(
        transactions,
        title: baseName,
        startDate:
            transactions.isNotEmpty ? transactions.last.date : DateTime.now(),
        endDate:
            transactions.isNotEmpty ? transactions.first.date : DateTime.now(),
      );

      // Exporter en JSON
      final jsonPath = await exportToJson(transactions);

      if (kDebugMode) {
        debugPrint('Export terminé:');
      }
      if (kDebugMode) {
        debugPrint('CSV: ${csvFile.path}');
      }
      if (kDebugMode) {
        debugPrint('PDF: ${pdfFile.path}');
      }
      if (kDebugMode) {
        debugPrint('JSON: $jsonPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur export multiple: $e');
      }
      rethrow;
    }
  }
}
