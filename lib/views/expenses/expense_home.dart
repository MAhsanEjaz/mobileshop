import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopapp/controllers/expense_controller.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/views/home_screen.dart';
import 'package:shopapp/views/sign_in_screen.dart';
import 'package:shopapp/widgets/animated_widget.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';
import 'package:table_calendar/table_calendar.dart';

class ExpenseHome extends StatefulWidget {
  const ExpenseHome({super.key});

  @override
  State<ExpenseHome> createState() => _ExpenseHomeState();
}

class _ExpenseHomeState extends State<ExpenseHome> {
  bool titleValid = false;
  bool amountValid = false;

  DateTime _selectedDay = DateTime.now();

  ExpenseController expenseController = Get.find();

  TextEditingController title = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();

  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: expenseController,
      builder: (cont) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: appColor,
            actions: [
              cont.isExpense
                  ? InkWell(
                    onTap: () {
                      cont.closeExpense();
                    },
                    child: Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: Colors.white,
                    ),
                  )
                  : SizedBox.shrink(),
              SizedBox(width: 14),
              InkWell(
                onTap: () {
                  customDialogInterFace(
                    filterDialog(
                      onTap: () async {
                        await cont.getExpense(startDate.text.toString(),endDate.text.toString());
                        exitLoader();
                      },
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
            title: Text('Expenses', style: TextStyle(color: Colors.white)),
          ),
          body: GetBuilder(
            init: expenseController,
            builder: (cont) {
              return cont.isExpense
                  ? expenseCard(cont)
                  : CustomAnimatedCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TableCalendar(
                                        firstDay: DateTime.utc(2020, 1, 1),
                                        lastDay: DateTime.utc(2030, 12, 31),

                                        calendarFormat: CalendarFormat.week,

                                        onDaySelected: (d, DateTime? day) {
                                          print('day-->$day');
                                          _selectedDay = day!;
                                          setState(() {});
                                        },
                                        daysOfWeekVisible: true,

                                        headerStyle: HeaderStyle(
                                          titleCentered: true,
                                          formatButtonVisible: false,
                                          leftChevronIcon: Container(
                                            child: Icon(
                                              Icons.chevron_left,
                                              color: Colors.white,
                                            ),
                                          ),
                                          rightChevronIcon: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                            ),
                                          ),
                                          titleTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        selectedDayPredicate: (day) {
                                          return isSameDay(_selectedDay, day);
                                        },
                                        daysOfWeekStyle: DaysOfWeekStyle(
                                          weekdayStyle: TextStyle(
                                            color: Colors.white70,
                                          ),
                                          weekendStyle: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        calendarStyle: CalendarStyle(
                                          defaultTextStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          weekendTextStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          selectedDecoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          outsideDaysVisible: false,
                                          selectedTextStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        focusedDay: DateTime.now(),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 15),
                                  AppTextField(
                                    hint: 'Title',
                                    controller: title,
                                    validationText: 'Please enter title',
                                    validation: titleValid,
                                  ),
                                  AppTextField(
                                    hint: 'Amount',
                                    controller: amount,
                                    validationText: 'Please enter amount',
                                    validation: amountValid,
                                  ),
                                  AppTextField(
                                    hint: 'Description',
                                    controller: description,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GetBuilder(
                            init: expenseController,
                            builder: (exp) {
                              return SafeArea(
                                child: AppButton(
                                  txt: 'Save',
                                  width: double.infinity,
                                  height: 45,
                                  onTap: () {
                                    if (validation()) {
                                      Map<String, dynamic> body = {
                                        "title": title.text.trim(),
                                        "amount": amount.text.trim(),
                                        "description": description.text.trim(),
                                        "date": dateFormatWithName(
                                          _selectedDay.toString(),
                                        ),
                                      };

                                      exp.addExpense(body);
                                    }

                                    setState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
            },
          ),
        );
      },
    );
  }

  bool validation() {
    return FieldValidator.validateFields([
      FieldItem(
        controller: title,
        setError: (v) {
          titleValid = v;
        },
      ),

      FieldItem(
        controller: amount,
        setError: (v) {
          amountValid = v;
        },
      ),
    ]);
  }

  Widget expenseCard(ExpenseController cont) {
    return Column(
      children: [
        SizedBox(height: 10),
        Expanded(
          child: GetBuilder(
            init: expenseController,
            builder: (cont) {
              return ListView.builder(
                itemCount: cont.expense.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final expense = cont.expense[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.blue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.title ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  expense.description ?? "",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount
                          Text(
                            numberFormat(num.parse(expense.amount.toString())),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Expense',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'PKR: ${numberFormat(cont.totalExpense)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
