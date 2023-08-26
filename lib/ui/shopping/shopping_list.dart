import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/models.dart';
import '../../data/repository.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  // TODO 1
  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final checkBoxValues = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<Repository>(context, listen: false);
    return StreamBuilder(
        stream: repository.watchAllIngredients(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final ingredients = snapshot.data;
            if (ingredients == null) {
              return Container();
            } else {
              return ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CheckboxListTile(
                      value: checkBoxValues.containsKey(index) &&
                          checkBoxValues[index]!,
                      title: Text(ingredients[index].name ?? ''),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            checkBoxValues[index] = newValue;
                          });
                        }
                      },
                    );
                  });
            }
          } else {
            return Container();
          }
        });
  }
}
