import '../../data/models/quote_model.dart';
import '../../core/services/local_storage_service.dart';

// Handles CRUD operations with local storage
class QuoteRepository {
  final LocalStorageService _storageService;
  QuoteRepository(this._storageService);
  Future<void> saveQuote(QuoteModel quote) async {
    await _storageService.saveQuote(quote);
  }
}
