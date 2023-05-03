import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class countrySearch extends StatefulWidget {
  const countrySearch({super.key});

  @override
  State<countrySearch> createState() => _countrySearchState();
}

class _countrySearchState extends State<countrySearch> {
  List<String> locationList = [
    "United States of America",
    "United Kingdom",
    "Belgium",
    "Malaysia",
    "Indonesia",
    "Germany",
    "Austria",
    "Hungary",
    "Nicaragua",
    "Argentina",
    "Japan",
    "United Arab Emirates",
    "Burundi",
  ];
  String selectedLocation = 'United States of America';
  String? countryData;
  bool isLoading = false;
  bool showFlag = false;
  String? flagIso;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Country Statistics App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1.0))),
            ),
            preferredSize: Size.fromHeight(4.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              children: [
                Text(
                  "Search for a \ncountry.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Container(
              width: size.width * 0.9,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.black, width: 1.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButton(
                  value: selectedLocation,
                  onChanged: (newValue) {
                    setState(() {
                      selectedLocation = newValue as String;
                    });
                  },
                  items: locationList.map((selectedLocation) {
                    return DropdownMenuItem(
                      value: selectedLocation,
                      child: Text(selectedLocation),
                    );
                  }).toList(),
                  icon: Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            ElevatedButton(
              onPressed: () async {
                _loadStatistics(selectedLocation);
                setState(() {
                  isLoading = true;
                  showFlag = false;
                });
                var country = await _loadStatistics(selectedLocation);
                print("Pressed!");
                setState(() {
                  isLoading = false;
                  countryData = buildSentence(
                      country.name,
                      country.region,
                      country.capital,
                      country.homicide_status,
                      country.population,
                      country.employAverage,
                      country.currencyName);
                  print(country.iso2);
                  flagIso = "https://flagsapi.com/${country.iso2}/flat/64.png";
                  showFlag = true;
                });
              },
              child: Text("Search Data!"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black)),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            if (showFlag)
              Container(
                width: size.width * 0.95,
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 31, 29, 29).withOpacity(0.8),
                      spreadRadius: 5,
                      blurRadius: 5,
                      offset: Offset(0, 10),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(flagIso!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(
              height: size.height * 0.05,
            ),
            isLoading
                ? CircularProgressIndicator()
                : Text(
                    countryData ?? "",
                    textAlign: TextAlign.justify,
                  )
          ],
        ),
      ),
    );
  }
}

_loadStatistics(String selectedLocation) async {
  var api_key = "1BpB0W1pSVpF7OuIFW8WWw==itG3rhVqgeeD7pbJ";
  var url =
      Uri.parse('https://api.api-ninjas.com/v1/country?name=$selectedLocation');
  var response = await http.get((url), headers: {'X-Api-Key': api_key});
  var rescode = response.statusCode;
  if (rescode == 200) {
    // Number 1
    // Retrieve and decode JSON Data
    var data = json.decode(response.body);
    if (data is List && data.isNotEmpty) {
      var countryData = data[0];
      // Datas of the country
      var iso2 = countryData['iso2'];
      var name = countryData['name'];
      // Number 2
      // Create instance of a capital country data from the decoded JSON
      var capital = countryData['capital'];
      var region = countryData['region'];
      var gdp = countryData['gdp'];
      // Number 2
      // Create instance of a currency name data from the decoded JSON
      var currencyName = countryData['currency']['name'];
      //Employment
      var employment_services = countryData['employment_services'];
      var employment_industry = countryData['employment_industry'];
      var employment_agriculture = countryData['employment_agriculture'];
      //Calculate Employment
      var employAverage = ((employment_services +
                  employment_agriculture +
                  employment_industry) /
              3)
          .toStringAsFixed(2);
      //Homicide Rate
      var homicide_rate = countryData['homicide_rate'];
      //Determine Homicide
      var homicide_status = "safe";
      if (homicide_rate > 5) {
        homicide_status = "unsafe";
      } else if (homicide_rate == 5) {
        homicide_status = "somewhat safe";
      }
      var population = countryData['population'].toStringAsFixed(2);
      // String  to make the sentence
      CountryData country = new CountryData(
          name: name,
          capital: capital,
          region: region,
          gdp: gdp,
          currencyName: currencyName,
          employment_services: employment_services,
          employment_industry: employment_industry,
          employment_agriculture: employment_agriculture,
          employAverage: employAverage,
          homicide_status: homicide_status,
          population: population,
          iso2: iso2);
      return country;
      // Number 4, and else condition if the first condition is not found
    } else {
      return "Country is not found!";
    }
  } else {
    return "Request failed with response code $rescode";
  }
}

String buildSentence(name, region, capital, String homicide_status, population,
    employAverage, currencyName) {
  String sentence =
      "Welcome to the $name! A country located on $region with $capital as the capital city! A $homicide_status country with the population of $population and the employment average of $employAverage! Using the currency of $currencyName.";
  return sentence;
}

class CountryData {
  var name;
  var capital;
  var region;
  var gdp;
  var currencyName;
  var employment_services;
  var employment_industry;
  var employment_agriculture;
  var employAverage;
  var homicide_status;
  var population;
  var iso2;

  CountryData(
      {required this.name,
      required this.capital,
      required this.region,
      required this.gdp,
      required this.currencyName,
      required this.employment_services,
      required this.employment_industry,
      required this.employment_agriculture,
      required this.employAverage,
      required this.homicide_status,
      required this.population,
      required this.iso2});
}
