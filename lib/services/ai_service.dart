import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/models/goal.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');
  }

  List<Transaction> _getRecentTransactions(
      List<Transaction> transactions, int limit) {
    final sorted = transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  Future<String> analyzeTransactions(
      List<Transaction> transactions, List<Goal> goals) async {
    try {
      final limitedTransactions = _getRecentTransactions(transactions, 10);
      final prompt = _createTransactionSummary(limitedTransactions, goals);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ??
          'Je ne peux pas analyser vos données pour le moment.';
    } catch (e) {
      return 'Erreur lors de l\'analyse: $e';
    }
  }

  Future<Map<String, dynamic>> predictNextMonthExpenses(
      List<Transaction> transactions, List<Goal> goals) async {
    try {
      final limitedTransactions =
          _getRecentTransactions(transactions, 20); // More for prediction
      final prompt = _createPredictionData(limitedTransactions, goals);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final contentText = response.text ?? '';
      return _parsePredictionResponse(contentText);
    } catch (e) {
      return {
        'total': 0.0,
        'categories': {},
        'confidence': 0.0,
        'recommendations': []
      };
    }
  }

  Future<List<String>> getFinancialTips(
      List<Transaction> transactions, List<Goal> goals) async {
    try {
      final limitedTransactions = _getRecentTransactions(transactions, 10);
      final prompt = _createTipsPrompt(limitedTransactions, goals);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final contentText = response.text ?? '';
      return _extractTips(contentText);
    } catch (e) {
      return [
        'Établissez un budget mensuel réaliste',
        'Suivez vos dépenses quotidiennement',
        'Épargnez au moins 20% de vos revenus',
        'Évitez les achats impulsifs',
        'Revoyez vos abonnements régulièrement'
      ];
    }
  }

  String _createTransactionSummary(
      List<Transaction> transactions, List<Goal> goals) {
    final expenseTransactions = transactions.where((t) => t.isExpense).toList();
    final incomeTransactions = transactions.where((t) => !t.isExpense).toList();

    double totalExpense =
        expenseTransactions.fold(0, (sum, t) => sum + t.amount);
    double totalIncome = incomeTransactions.fold(0, (sum, t) => sum + t.amount);

    final categoryTotals = <String, double>{};
    for (var transaction in expenseTransactions) {
      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String goalsSummary = '';
    if (goals.isNotEmpty) {
      goalsSummary = '''
      
      Objectifs financiers:
      ${goals.map((g) => '- ${g.name}: \$${g.currentAmount.toStringAsFixed(2)} / \$${g.targetAmount.toStringAsFixed(2)} (${g.deadline != null ? 'Échéance: ${g.deadline!.toLocal().toString().split(' ')[0]}' : ''})').join('\n')}
      ''';
    }

    String summary = '''
    Voici un résumé de vos 10 dernières transactions financières:
    
    Total des revenus: \$${totalIncome.toStringAsFixed(2)}
    Total des dépenses: \$${totalExpense.toStringAsFixed(2)}
    Économies: \$${(totalIncome - totalExpense).toStringAsFixed(2)}
    
    Dépenses par catégorie (top 5):
    ${sortedCategories.take(5).map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}
    
    Nombre de transactions analysées: ${transactions.length}
    Période: Transactions récentes$goalsSummary
    
    En tant qu'assistant financier expert, analyse ces données et donne des conseils personnalisés pour améliorer ta gestion budgétaire.
    ''';

    return summary;
  }

  String _createTipsPrompt(List<Transaction> transactions, List<Goal> goals) {
    final summary = _createTransactionSummary(transactions, goals);
    return '''
    $summary
    
    En tant qu'expert en finance personnelle, fournis 5 à 7 conseils pratiques et personnalisés pour améliorer ma gestion budgétaire. Concentre-toi sur des actions concrètes que je peux mettre en place immédiatement.
    
    Formate ta réponse sous forme de liste numérotée ou à puces.
    ''';
  }

  String _createPredictionData(
      List<Transaction> transactions, List<Goal> goals) {
    final monthlyData = <String, Map<String, double>>{};

    for (var transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';

      monthlyData.putIfAbsent(
          monthKey,
          () => {
                'expense': 0.0,
                'income': 0.0,
              });

      if (transaction.isExpense) {
        monthlyData[monthKey]!['expense'] =
            monthlyData[monthKey]!['expense']! + transaction.amount;
      } else {
        monthlyData[monthKey]!['income'] =
            monthlyData[monthKey]!['income']! + transaction.amount;
      }
    }

    String goalsSummary = '';
    if (goals.isNotEmpty) {
      goalsSummary = '''
      
      Objectifs à atteindre:
      ${goals.map((g) => '- ${g.name}: Cible \$${g.targetAmount.toStringAsFixed(2)}, Actuel \$${g.currentAmount.toStringAsFixed(2)}').join('\n')}
      ''';
    }

    return '''
    Données des 20 dernières transactions groupées par mois:
    ${monthlyData.entries.map((e) => '${e.key}: Revenus=\$${e.value['income']!.toStringAsFixed(2)}, Dépenses=\$${e.value['expense']!.toStringAsFixed(2)}').join('\n')}$goalsSummary
    
    En tant qu'expert en prédiction financière, analyse ces données historiques et prédit les dépenses du mois prochain. Fournis une estimation réaliste du total des dépenses, une répartition par catégories principales, un niveau de confiance (0-1), et des recommandations pour optimiser les dépenses.
    
    Réponds en format JSON: {"total": montant, "categories": {"catégorie": montant}, "confidence": 0.8, "recommendations": ["conseil1", "conseil2"]}
    ''';
  }

  Map<String, dynamic> _parsePredictionResponse(String response) {
    try {
      // Chercher du JSON dans la réponse
      final jsonMatch =
          RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(response);
      final jsonString = jsonMatch?.group(1) ?? response;

      final data = jsonDecode(jsonString);
      return {
        'total': data['total'] ?? 0.0,
        'categories': Map<String, double>.from(data['categories'] ?? {}),
        'confidence': data['confidence'] ?? 0.0,
        'recommendations': List<String>.from(data['recommendations'] ?? [])
      };
    } catch (e) {
      // Fallback parsing
      return {
        'total': _extractNumberFromText(response, 'total'),
        'categories': _extractCategoriesFromText(response),
        'confidence': _extractConfidenceFromText(response),
        'recommendations': _extractRecommendationsFromText(response)
      };
    }
  }

  List<String> _extractTips(String content) {
    final tips = <String>[];
    final lines = content.split('\n');

    for (var line in lines) {
      final match = RegExp(r'^(\d+\.|[-•])\s*(.+)$').firstMatch(line);
      if (match != null) {
        tips.add(match.group(2)!.trim());
      }
    }

    return tips.isNotEmpty
        ? tips
        : content.split('. ').where((s) => s.length > 10).toList();
  }

  double _extractNumberFromText(String text, String keyword) {
    final pattern = RegExp('$keyword[\\s:]*\\\$?([\\d,.]+)');
    final match = pattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, double> _extractCategoriesFromText(String text) {
    final categories = <String, double>{};
    final lines = text.split('\n');

    for (var line in lines) {
      final match = RegExp(r'[-•]\s*([^:]+):\s*\$?([\d,.]+)').firstMatch(line);
      if (match != null) {
        final category = match.group(1)!.trim();
        final amount =
            double.tryParse(match.group(2)!.replaceAll(',', '')) ?? 0.0;
        categories[category] = amount;
      }
    }

    return categories;
  }

  double _extractConfidenceFromText(String text) {
    final pattern = RegExp(r'confiance[:\s]*([\d.]+)%?');
    final match = pattern.firstMatch(text.toLowerCase());
    if (match != null) {
      final value = double.tryParse(match.group(1)!) ?? 0.0;
      return value > 1 ? value / 100 : value;
    }
    return 0.7; // Valeur par défaut
  }

  List<String> _extractRecommendationsFromText(String text) {
    final recommendations = <String>[];
    final sentences = text.split('. ');

    for (var sentence in sentences) {
      if (sentence.toLowerCase().contains(
              RegExp(r'(conseil|recommandation|suggestion|devriez|pouvez)')) &&
          sentence.length > 20) {
        recommendations.add(sentence.trim());
      }
    }

    return recommendations.take(3).toList();
  }

  Future<String> chatWithAI(String userMessage, List<Transaction> transactions,
      List<Goal> goals) async {
    try {
      final limitedTransactions = _getRecentTransactions(transactions, 10);
      final context = _createTransactionSummary(limitedTransactions, goals);
      final prompt = '''
      Contexte de l'utilisateur (basé sur les 10 dernières transactions):
      $context
      
      Message de l'utilisateur: $userMessage
      
      Réponds en tant qu'assistant financier expert. Sois utile, précis et encourageant. Concentre-toi sur la gestion budgétaire, les investissements et les conseils financiers.
      ''';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Désolé, je n\'ai pas pu générer une réponse.';
    } catch (e) {
      if (e.toString().contains('quota') ||
          e.toString().contains('rate limit') ||
          e.toString().contains('429')) {
        return 'Quota atteint. Réessayez dans quelques minutes ou passez au forfait payant Blaze.';
      }
      return 'Erreur lors de la génération de la réponse: $e';
    }
  }
}
