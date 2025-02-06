import 'package:flutter/material.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemondetailView extends StatefulWidget {
  final PokemonListItem pokemonListItem;

  const PokemondetailView({Key? key, required this.pokemonListItem})
      : super(key: key);

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final url =
        'https://pokeapi.co/api/v2/pokemon/${widget.pokemonListItem.name}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _pokemonData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonListItem.name),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text("Failed to load Pokémon details"))
              : _pokemonData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pokémon Image
                          Image.network(
                            _pokemonData!['sprites']['front_default'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error,
                                    size: 100, color: Colors.red),
                          ),
                          const SizedBox(height: 20),

                          // Pokémon Name
                          Text(
                            widget.pokemonListItem.name.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 10),

                          // Pokémon Types
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _pokemonData!['types']
                                .map<Widget>(
                                  (type) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Chip(
                                      label: Text(
                                        type['type']['name'].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 20),

                          // Base Stats
                          const Text(
                            "Base Stats",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          Column(
                            children: _pokemonData!['stats']
                                .map<Widget>(
                                  (stat) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(stat['stat']['name']),
                                        Text(stat['base_stat'].toString()),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text("No data available")),
    );
  }
}
