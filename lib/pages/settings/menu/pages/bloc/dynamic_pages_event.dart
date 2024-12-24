import 'package:querier/models/page.dart';

abstract class DynamicPagesEvent {}

class LoadPages extends DynamicPagesEvent {
  final int categoryId;
  LoadPages(this.categoryId);
}

class DeletePage extends DynamicPagesEvent {
  final int pageId;
  DeletePage(this.pageId);
}

class CreatePage extends DynamicPagesEvent {
  final MenuPage page;
  CreatePage(this.page);
}

class UpdatePage extends DynamicPagesEvent {
  final MenuPage page;
  UpdatePage(this.page);
}

class UpdatePageVisibility extends DynamicPagesEvent {
  final MenuPage page;
  final bool isVisible;
  UpdatePageVisibility(this.page, this.isVisible);
}
