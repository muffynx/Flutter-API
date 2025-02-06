import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<PokemonListItem> _pokemonList = [];
  String? _nextUrl = 'https://pokeapi.co/api/v2/pokemon'; // Initial URL
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData(); // Load the first page

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _nextUrl != null) {
        loadData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ ล้าง Scroll Controller
    super.dispose();
  }

  // ✅ โหลดข้อมูลโปเกมอน
  Future<void> loadData() async {
    if (_isLoading || _nextUrl == null) return; // ป้องกันการโหลดซ้ำ
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(_nextUrl!));
      if (response.statusCode == 200) {
        final data = PokemonListResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _pokemonList.addAll(data.results); // เพิ่มข้อมูลใหม่
          _nextUrl = data.next; // อัปเดต URL สำหรับหน้าถัดไป
        });
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ รีเฟรชข้อมูลใหม่
  Future<void> refreshData() async {
    setState(() {
      _pokemonList.clear();
      _nextUrl = 'https://pokeapi.co/api/v2/pokemon';
    });
    await loadData(); // โหลดข้อมูลใหม่
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData, // ดึงเพื่อรีเฟรช
      child: ListView.builder(
        controller: _scrollController, // ✅ กำหนด Scroll Controller
        itemCount: _pokemonList.length + 1, // +1 สำหรับ footer
        itemBuilder: (context, index) {
          if (index < _pokemonList.length) {
            final pokemon = _pokemonList[index];
            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  pokemon.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
              title: Text(pokemon.name),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PokemondetailView(pokemonListItem: pokemon),
                ),
              ),
            );
          } else {
            // ✅ Footer: แสดงสถานะโหลดหรือข้อความว่า "ไม่มีข้อมูลเพิ่มเติม"
            if (_nextUrl == null) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'ไม่มีข้อมูลเพิ่มเติม',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            } else if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const SizedBox.shrink(); // ซ่อน Footer ถ้าไม่โหลด
            }
          }
        },
      ),
    );
  }
}
