import 'package:flutter/material.dart';

class MeetingWidgets{


  static  Widget buildTableSection({
    required String title,
    String? subtitle,
    Widget? actionButton,
    required Widget child,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actionButton != null) actionButton,
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }


  static  Widget buildDataTable({
    required BuildContext context,
    required List<String> columns,
    required List<List<dynamic>> rows,
     }) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 64,
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            border: TableBorder.all(color: Colors.grey.shade300),
            columnSpacing: 20,
            columns:
                columns
                    .map(
                      (column) => DataColumn(
                        label: Expanded(
                          child: Text(
                            column,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                    .toList(),
            rows:
                rows
                    .map(
                      (row) => DataRow(
                        cells:
                            row
                                .map(
                                  (cell) => DataCell(
                                    Container(
                                      width: double.infinity,
                                      child:
                                          cell is Widget
                                              ? cell
                                              : Text(cell.toString()),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }



   static  Widget buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present':
      case 'paid':
        color = Colors.green;
        break;
      case 'late':
      case 'pending':
        color = Colors.orange;
        break;
      case 'absent':
      case 'unpaid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


}