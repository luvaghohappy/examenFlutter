import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Caisserapport extends StatefulWidget {
  const Caisserapport({Key? key}) : super(key: key);

  @override
  State<Caisserapport> createState() => _CaisserapportState();
}

class _CaisserapportState extends State<Caisserapport> {
  TextEditingController txtdate = TextEditingController();
  List<Map<String, dynamic>> items = [];
  double montantTotal = 0.0;
  double solde = 0.0;

  //calculer total
  int totalMontant = 0;
  Future<void> calculer() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:81/inscription/calculetotal.php'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        int total = data['total'];
        setState(() {
          totalMontant = total;
        });
      } else {
        throw Exception('Failed to fetch total amount');
      }
    } catch (e) {
      print('Error calculating total: $e');
      // Handle error
    }
  }

  // Fonction pour sélectionner la date
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    calculer(); // Load initial data when the app starts
  }

  // Fonction pour récupérer les données depuis le serveur
  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:81/inscription/chargerrapport.php"),
      );

      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

// Fonction pour effectuer une requête HTTP avec une date spécifique
  Future<void> fetchDataByDate(String date) async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost:81/inscription/rapportdate.php?R_date=$date"),
      );

      setState(() {
        final jsonData = json.decode(response.body);
        final montantTotal = double.parse(jsonData['MontantTotal']);
        final solde = montantTotal - this.montantTotal; // Calcul du solde

        items = List<Map<String, dynamic>>.from(jsonData['data']);
        this.montantTotal = montantTotal;
        this.solde = solde; // Mettre à jour le solde
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

// Fonction pour gérer la recherche par date
  void searchByDate() {
    String date = DateFormat('yyyy-MM-dd')
        .format(DateTime.now()); // Par défaut, utilise la date actuelle

    // Si le champ de texte contient une date valide, utilisez cette date
    if (txtdate.text.isNotEmpty) {
      date = DateFormat('yyyy-MM-dd').format(DateTime.parse(txtdate.text));
    }

    fetchDataByDate(
        date); // Appel de la fonction pour récupérer les données par date spécifique
  }

// Fonction pour effacer les résultats de recherche et afficher tous les résultats
  void clearSearch() {
    fetchData(); // Chargez à nouveau les données initiales
    txtdate.clear(); // Effacez le champ de texte de la date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: TextField(
                controller: txtdate,
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  fillColor: Colors.grey,
                  labelText: 'Recherche Date',
                  hintText: 'Date',
                  prefixIcon: IconButton(
                    iconSize: 15,
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                  suffixIcon: IconButton(
                    // Ajout d'un bouton de recherche
                    onPressed: searchByDate,
                    icon: const Icon(Icons.search),
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
            ),
            DataTable(
              columns: const [
                DataColumn(
                  label: Text('MontantTotal'),
                ),
                DataColumn(
                  label: Text('Date'),
                ),
              ],
              rows: items.map<DataRow>((item) {
                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) {
                      return Colors.grey.shade200;
                    },
                  ),
                  cells: [
                    DataCell(
                      Text(item['MontantTotal'].toString()),
                    ),
                    DataCell(
                      Text(item['Dates'].toString()),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Text(
              'Somme Total: $totalMontant',
              style: const TextStyle(fontSize: 15),
            ),
            TextButton(
              onPressed: calculer,
              child: const Text('Total'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            ElevatedButton(
              onPressed: clearSearch,
              child: const Text("Quitter"),
            )
          ],
        ),
      ),
    );
  }
}
