import '../../data/models/quote_model.dart';
import '../../core/services/local_storage_service.dart';

/// Repository for managing quotes
/// Handles CRUD operations with local storage
class QuoteRepository {
  final LocalStorageService _storageService;

  QuoteRepository(this._storageService);

  /// Get all quotes
  Future<List<QuoteModel>> getAllQuotes() async {
    try {
      return await _storageService.getQuotes();
    } catch (e) {
      return [];
    }
  }

  /// Get quote by ID
  Future<QuoteModel?> getQuoteById(String id) async {
    final quotes = await getAllQuotes();
    return quotes.where((quote) => quote.id == id).firstOrNull;
  }

  /// Save a quote
  Future<void> saveQuote(QuoteModel quote) async {
    await _storageService.saveQuote(quote);
  }

  /// Delete a quote
  Future<void> deleteQuote(String id) async {
    await _storageService.deleteQuote(id);
  }

  /// Get recent quotes (last 10)
  Future<List<QuoteModel>> getRecentQuotes() async {
    final quotes = await getAllQuotes();
    quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quotes.take(10).toList();
  }

  /// Search quotes by client name
  Future<List<QuoteModel>> searchQuotesByClient(String clientName) async {
    final quotes = await getAllQuotes();
    return quotes
        .where((quote) =>
            quote.clientName.toLowerCase().contains(clientName.toLowerCase()))
        .toList();
  }

  /// Get quotes created in date range
  Future<List<QuoteModel>> getQuotesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final quotes = await getAllQuotes();
    return quotes
        .where((quote) =>
            quote.createdAt.isAfter(startDate) &&
            quote.createdAt.isBefore(endDate))
        .toList();
  }

  /// Get total quotes count
  Future<int> getTotalQuotesCount() async {
    final quotes = await getAllQuotes();
    return quotes.length;
  }
}
