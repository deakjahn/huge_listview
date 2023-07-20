import 'package:flutter/material.dart';

class HugeListViewController {
  void Function()? onReload;
  void Function(bool reloadPage)? onInvalidateList;
  void Function(int)? setTotalItemCount;

  set totalItemCount(int count) {
    if (setTotalItemCount != null) {
      setTotalItemCount!(count);
    } else {
      throw Exception('HugeListController not connected to HugeListView');
    }
  }

  void reload() {
    if (onReload != null) {
      onReload!();
    } else {
      throw Exception('HugeListController not connected to HugeListView');
    }
  }

  void invalidateList(bool reloadPage) {
    if (onInvalidateList != null) {
      onInvalidateList!(reloadPage);
    } else {
      throw Exception('HugeListController not connected to HugeListView');
    }
  }
}
