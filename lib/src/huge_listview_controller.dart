class HugeListViewController {
  void Function()? onReload;
  void Function(bool reloadPage)? onInvalidateList;
  void Function(int)? setTotalItemCount;

  void reload() {
    if (onReload != null) {
      onReload!();
    }
  }

  void invalidateList(bool reloadPage) {
    if (onInvalidateList != null) {
      onInvalidateList!(reloadPage);
    }
  }

  void setTotalItemCounty(int count) {
    if (setTotalItemCount != null) {
      setTotalItemCount!(count);
    }
  }
}
