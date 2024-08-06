import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _input = "";
  double num1 = 0;
  String operand = "";

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _input = "";
        num1 = 0;
        operand = "";
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        num1 = double.parse(_output);
        operand = buttonText;
        _input = _output + buttonText;
        _output = "0";
      } else if (buttonText == "=") {
        double num2 = double.parse(_output);
        switch (operand) {
          case "+":
            _output = (num1 + num2).toString();
            break;
          case "-":
            _output = (num1 - num2).toString();
            break;
          case "×":
            _output = (num1 * num2).toString();
            break;
          case "÷":
            _output = (num1 / num2).toString();
            break;
        }
        _input = "";
        num1 = 0;
        operand = "";
      } else if (buttonText == "+/-") {
        if (_output.startsWith("-")) {
          _output = _output.substring(1);
        } else {
          _output = "-" + _output;
        }
      } else if (buttonText == "%") {
        double num = double.parse(_output);
        _output = (num / 100).toString();
      } else {
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  Widget _buildButton(String buttonText, {Color color = Colors.white, Color textColor = Colors.green}) {
    return Expanded(
      child: ElevatedButton(
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 24, color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: EdgeInsets.all(24),
        ),
        onPressed: () => _buttonPressed(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Text(
              _input,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Text(
              _output,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Divider(),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("C"),
                  _buildButton("+/-"),
                  _buildButton("%"),
                  _buildButton("÷"),
                ],
              ),
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("×"),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("-"),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("+"),
                ],
              ),
              Row(
                children: [
                  _buildButton(","),
                  _buildButton("0"),
                  _buildButton("⌫"),
                  _buildButton("=", color: Colors.orange, textColor: Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}