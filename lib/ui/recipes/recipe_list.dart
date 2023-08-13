import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/recipe_model.dart';
import '../../network/recipe_service.dart';
import '../colors.dart';
import '../recipe_card.dart';
import '../widgets/custom_dropdown.dart';
import 'recipe_details.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';

  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();

  // 현재 검색 결과 데이터를 담고 있다.
  List<APIHits> currentSearchList = [];
  // 1회 쿼리 검색이 얼마나 많은 결과를 담고 있나(`APIRecipeQuery.count`에 대응)
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  // 한번에 데이터를 잡아올 window의 크기
  final int pageCount = 20;

  // 지정된 범위 외에 결과가 더 있는가?
  bool hasMore = false;
  bool loading = false;

  // 통신 결과가 에러였는지 저장한 플래그
  bool inErrorState = false;

  // 이전 검색 키워드들을 담고 있다.
  List<String> previousSearches = <String>[];

  @override
  void initState() {
    super.initState();
    getPreviousSearches();
    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      // 매 픽셀 스크롤 될 때마다 실행될 콜백.
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;
      // 70% 이상에 도달했을 때 더 읽을 검색 결과가 있으면 화면 갱신.
      final didScrollbarStepOver =
          _scrollController.position.pixels > triggerFetchMoreSize;
      if (didScrollbarStepOver &&
          hasMore &&
          currentEndPosition < currentCount &&
          !loading &&
          !inErrorState) {
        setState(() {
          loading = true;
          currentStartPosition = currentEndPosition;
          currentEndPosition =
              min(currentStartPosition + pageCount, currentCount);
        });
      }
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
    final recipeJson = await RecipeService().getRecipes(query, from, to);
    final recipeMap = json.decode(recipeJson);
    return APIRecipeQuery.fromJson(recipeMap);
  }

  void savePreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      final searches = prefs.getStringList(prefSearchKey);
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                startSearch(searchTextController.text);
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search'),
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      startSearch(searchTextController.text);
                    },
                    controller: searchTextController,
                  )),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              previousSearches.remove(value);
                              savePreviousSearches();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startSearch(String keyword) {
    setState(() {
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      keyword = keyword.trim();
      if (!previousSearches.contains(keyword)) {
        previousSearches.add(keyword);
        savePreviousSearches();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (searchTextController.text.length < 3) {
      return Container();
    }

    // Future의 상태에 따라 어떤 위젯을 빌드할지 결정할 수 있다.
    return FutureBuilder<APIRecipeQuery>(
      future: getRecipeData(searchTextController.text.trim(),
          currentStartPosition, currentEndPosition),
      builder: (context, snapshot) {
        /* |- notDone
         * |- done
         *     |- error
         *     |- data
         */
        if (snapshot.connectionState == ConnectionState.done) {
          // 통신 중 에러를 만난 경우 리턴할 위젯 결정.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                textScaleFactor: 1.3,
              ),
            );
          }
          // 에러가 없는 경우 리턴할 위젯 결정.
          loading = false;
          final query = snapshot.data;
          inErrorState = false;
          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);
            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }
          }
          return _buildRecipeList(context, currentSearchList);
        } else {
          if (currentCount == 0) {
            // Show a loading indicator while waiting for the recipes.
            return const Center(child: CircularProgressIndicator());
          } else {
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
    );
  }

  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;

    return Flexible(
      child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: itemHeight / itemWidth,
          ),
          itemCount: hits.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildRecipeCard(recipeListContext, hits, index);
          }),
    );
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext,
            MaterialPageRoute(builder: (context) => const RecipeDetails()));
      },
      child: RecipeCard(recipe),
    );
  }
}
