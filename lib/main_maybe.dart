import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: FinancialDashboard(),
    );
  }
}

class FinancialDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu, size: 24),
                  Icon(Icons.notifications_none, size: 24),
                ],
              ),
              SizedBox(height: 20),
              Text('Total Balance', style: TextStyle(fontSize: 18)),
              Text(
                '\$31,632.39',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    AccountCard(
                      icon: 'assets/financial_icons/credit_card.svg',
                      title: 'Card',
                      amount: 28310,
                      color: Color(0xFFFFE5E5),
                    ),
                    AccountCard(
                      icon: 'assets/financial_icons/dollar_sign.svg',
                      title: 'Cash',
                      amount: 2640,
                      color: Color(0xFFE5F1FF),
                    ),
                    AccountCard(
                      icon: 'assets/financial_icons/piggy_bank.svg',
                      title: 'Savings',
                      amount: 2550,
                      color: Color(0xFFFFF5E5),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(Icons.add, size: 24, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.asset('assets/financial_icons/home.svg', width: 24, height: 24),
              SvgPicture.asset('assets/financial_icons/grid.svg', width: 24, height: 24),
              SvgPicture.asset('assets/financial_icons/bar_chart.svg', width: 24, height: 24),
              SvgPicture.asset('assets/financial_icons/user.svg', width: 24, height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final String icon;
  final String title;
  final int amount;
  final Color color;

  AccountCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(icon, width: 24, height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${amount.toString()}'),
            ],
          ),
        ],
      ),
    );
  }
}