/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/result_page.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pixez/page/search/trend_tags_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String editString = "";
  TrendTagsStore _trendTagsStore;

  @override
  void initState() {
    _controller = RefreshController(initialRefresh: true);
    _trendTagsStore = TrendTagsStore(_controller);
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    tagHistoryStore.fetch();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  RefreshController _controller;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (accountStore.now != null)
        return NestedScrollView(
            headerSliverBuilder: (BuildContext context,
                    bool innerBoxIsScrolled) =>
                [
                  _trendTagsStore.trendTags.isNotEmpty
                      ? SliverAppBar(
                          pinned: true,
                          title: Text(I18n.of(context).search),
                          centerTitle: false,
                          forceElevated: innerBoxIsScrolled,
                          expandedHeight:
                              200 + MediaQuery.of(context).padding.top,
                          flexibleSpace: FlexibleSpaceBar(
                            titlePadding: EdgeInsets.all(0.0),
                            collapseMode: CollapseMode.none,
                            background: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IllustPage(
                                    id: _trendTagsStore
                                        .trendTags.last.illust.id,
                                  ),
                                ));
                              },
                              child: ExtendedImage.network(
                                _trendTagsStore
                                    .trendTags.last.illust.imageUrls.medium,
                                fit: BoxFit.cover,
                                headers: PixivHeader,
                                height:
                                    200 + MediaQuery.of(context).padding.top,
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchSuggestionPage()));
                              },
                            )
                          ],
                        )
                      : SliverAppBar(
                          flexibleSpace: FlexibleSpaceBar(),
                          title: Text(I18n.of(context).search),
                        )
                ],
            body: _buildListView(context));
      return Column(children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            I18n.of(context).search,
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => SearchSuggestionPage()));
              },
            )
          ],
        ),
        Expanded(child: LoginInFirst())
      ]);
    });
  }

  TabController _tabController;

  Widget _buildListView(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      enablePullDown: true,
      onRefresh: () => _trendTagsStore.fetch(),
      child: ListView(padding: EdgeInsets.symmetric(horizontal: 8), children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(I18n.of(context).history),
        ),
        Observer(
          builder: (BuildContext context) {
            if (tagHistoryStore.tags.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Wrap(
                  children: tagHistoryStore.tags
                      .map((f) => ActionChip(
                            label: Text(f.name),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(
                                      builder: (context) => ResultPage(
                                            word: f.name,
                                            translatedName:
                                                f.translatedName ?? '',
                                          )));
                            },
                          ))
                      .toList()
                        ..add(ActionChip(
                            label: Text(I18n.of(context).clear),
                            onPressed: () {
                              tagHistoryStore.deleteAll();
                            })),
                  runSpacing: 0.0,
                  spacing: 3.0,
                ),
              );
            }
            return Container();
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(I18n.of(context).recommand_tag),
        ),
        _trendTagsStore.trendTags.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildGrid(context, _trendTagsStore.trendTags),
              )
            : Container()
      ]),
    );
  }

  Widget _buildGrid(BuildContext context, List<Trend_tags> tags) =>
      Observer(builder: (_) {
        return GridView.builder(
          padding: EdgeInsets.all(0.0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _trendTagsStore.trendTags.length - 1,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (_) {
                    return ResultPage(
                      word: tags[index].tag,
                    );
                  }));
                },
                onLongPress: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (_) {
                    return IllustPage(id: tags[index].illust.id);
                  }));
                },
                child: Stack(
                  children: <Widget>[
                    PixivImage(
                      tags[index].illust.imageUrls.squareMedium,
                    ),
                    Container(
                      decoration: BoxDecoration(color: Color(0x90000000)),
                    ),
                    Align(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              tags[index].tag,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
}
