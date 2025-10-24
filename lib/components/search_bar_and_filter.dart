import 'package:flutter/material.dart';

class SearchBarAndFilter extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarAndFilter({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchBarAndFilter> createState() => _SearchBarAndFilterState();
}

class _SearchBarAndFilterState extends State<SearchBarAndFilter> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: "Tìm kiếm địa điểm...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF647807)),
                filled: true,
                fillColor: Color(0xFFF7FAE9),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
