import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyectoagro/bloc/maquinaria_cb.dart';

class MaquinariaPage extends StatefulWidget {
  @override
  _MaquinariaPageState createState() => _MaquinariaPageState();
}

class _MaquinariaPageState extends State<MaquinariaPage> {
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = _searchController.text;

      if (searchTerm.length >= 2 || searchTerm.isEmpty) {
        context.read<MaquinariaCubit>().fetchMaquinarias(1, 10, search: searchTerm);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Maquinarias'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Maquinaria',
                hintText: 'Ingresa una Maquinaria',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MaquinariaCubit, MaquinariaState>(
              builder: (context, state) {
                if (state is MaquinariaLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MaquinariaEmpty) {
                  return Center(child: Text('No se encontraron maquinarias.'));
                } else if (state is MaquinariaLoaded) {
                  return ListView.builder(
                    itemCount: state.maquinarias.length,
                    itemBuilder: (context, index) {
                      final maquinaria = state.maquinarias[index];
                      return ListTile(
                        title: Text('${maquinaria.brand} - ${maquinaria.model}'),
                        subtitle: Text('Código: ${maquinaria.code}, Horas: ${maquinaria.hours}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            context.read<MaquinariaCubit>().deleteMaquinaria(maquinaria.id);
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('Se han encontrado 0 Maquinarias.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<MaquinariaCubit>().fetchMaquinarias(1, 10); 
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
