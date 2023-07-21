import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A controller to control the functionality of [HugeListView].
class HugeListViewController
    extends ValueNotifier<HugeListViewControllerValue> {
  /// Total number of items in the list.
  int get totalItemCount => value.totalItemCount;

  set totalItemCount(int newTotalItemCount) {
    value = value.copyWith(totalItemCount: newTotalItemCount);
    notifyListeners();
  }

  /// A controller for a [HugeListView] widget.
  ///
  /// Remember to [dispose] of the [HugeListViewController] when it's no longer needed.
  /// This will ensure we discard any resources used by the object.
  HugeListViewController({required int totalItemCount})
      : super(HugeListViewControllerValue(totalItemCount, false, false, false));

  /// Creates a controller for a [HugeListView] widget from an initial [HugeListViewControllerValue].
  HugeListViewController.fromValue(HugeListViewControllerValue value)
      : super(value);

  void reload() {
    value = value.copyWith(doReload: true);
    notifyListeners();
  }

  void invalidateList(bool reloadPage) {
    value = value.copyWith(doInvalidateList: true, reloadPage: reloadPage);
    notifyListeners();
  }
}

class HugeListViewControllerValue {
  final int totalItemCount;
  final bool doReload;
  final bool doInvalidateList;
  final bool reloadPage;

  const HugeListViewControllerValue(this.totalItemCount, this.doReload,
      this.doInvalidateList, this.reloadPage);

  HugeListViewControllerValue copyWith({
    int? totalItemCount,
    bool? doReload,
    bool? doInvalidateList,
    bool? reloadPage,
  }) =>
      HugeListViewControllerValue(
        totalItemCount ?? this.totalItemCount,
        doReload ?? false,
        doInvalidateList ?? false,
        reloadPage ?? this.reloadPage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HugeListViewControllerValue &&
        other.totalItemCount == totalItemCount &&
        other.doReload == doReload &&
        other.doInvalidateList == doInvalidateList &&
        other.reloadPage == reloadPage;
  }

  @override
  int get hashCode =>
      Object.hash(totalItemCount, doReload, doInvalidateList, reloadPage);
}
