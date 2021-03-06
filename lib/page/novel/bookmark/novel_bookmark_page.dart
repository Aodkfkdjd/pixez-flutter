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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelBookmarkPage extends StatefulWidget {
  final int id;

  const NovelBookmarkPage({Key key, this.id}) : super(key: key);
  @override
  _NovelBookmarkPageState createState() => _NovelBookmarkPageState();
}

class _NovelBookmarkPageState extends State<NovelBookmarkPage> {
  String restrict = 'public';
  FutureGet futureGet;
  @override
  void initState() {
    futureGet = () => apiClient.getUserBookmarkNovel(widget.id, restrict);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (int.parse(accountStore.now.userId) == widget.id)
        return Column(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text(I18n.of(context).public),
                                onTap: () {
                                  setState(() {
                                    futureGet = () =>
                                        apiClient.getUserBookmarkNovel(
                                            widget.id, 'public');
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                title: Text(I18n.of(context).private),
                                onTap: () {
                                  setState(() {
                                    futureGet = () =>
                                        apiClient.getUserBookmarkNovel(
                                            widget.id, 'private');
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      });
                }),
            NovelLightingList(
              futureGet: futureGet,
            )
          ],
        );
      else {
        return NovelLightingList(
          futureGet: futureGet,
        );
      }
    });
  }
}
