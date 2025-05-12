// Copyright (c) 2025 MOHAMED ATEF. 
// Licensed under the MIT License.

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}