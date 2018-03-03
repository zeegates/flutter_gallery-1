// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

enum _ListType {
  /// A list tile that contains a single line of text.
  oneLine,

  /// A list tile that contains a [CircleAvatar] followed by a single line of text.
  oneLineWithAvatar,

  /// A list tile that contains two lines of text.
  twoLine,

  /// A list tile that contains three lines of text.
  threeLine,
}

class EMSTaskList extends StatefulWidget {
  const EMSTaskList({ Key key }) : super(key: key);

  static const String routeName = '/ems/list';

  @override
  _ListState createState() => new _ListState();
}

class EMSTask {
  EMSTask(this.initials, this.title, this.description);
  int compareTo(EMSTask that) {
    return initials.compareTo(that.initials);
  }
  String initials;
  String title;
  String description;
}

class _ListState extends State<EMSTaskList> {
  static final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PersistentBottomSheetController<Null> _bottomSheet;
  _ListType _itemType = _ListType.threeLine;
  bool _dense = false;
  bool _showAvatars = true;
  bool _showIcons = false;
  bool _showDividers = false;
  bool _reverseSort = false;
  List<EMSTask> items = <EMSTask>[
    new EMSTask('SS', 'Scene Safe?', 'Is the scene safe?'),
    new EMSTask('ABC', 'Check ABCs?', 'Check Airway, Breathing and Circulation (including bleeding, skin to win!)'),
    new EMSTask('AO', 'Alert and Oriented?', 'Does the patient know their name? Do they know who is president? Do they know what happened?'),
    new EMSTask('OT', 'Other Stuff?', 'Is there other stuff?'),
    new EMSTask('OT', 'Other Stuff?', 'Is there other stuff?'),
    new EMSTask('OT', 'Other Stuff?', 'Is there other stuff?'),
    new EMSTask('OT', 'Other Stuff?', 'Is there other stuff?'),
    new EMSTask('OT', 'Other Stuff?', 'Is there other stuff?'),
  ];

  void changeItemType(_ListType type) {
    setState(() {
      _itemType = type;
    });
    _bottomSheet?.setState(() { });
  }

  void _showConfigurationSheet() {
    final PersistentBottomSheetController<Null> bottomSheet = scaffoldKey.currentState.showBottomSheet((BuildContext bottomSheetContext) {
      return new Container(
        decoration: const BoxDecoration(
          border: const Border(top: const BorderSide(color: Colors.black26)),
        ),
        child: new ListView(
          shrinkWrap: true,
          primary: false,
          children: <Widget>[
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Terse'),
                trailing: new Radio<_ListType>(
                  value: _showAvatars ? _ListType.oneLineWithAvatar : _ListType.oneLine,
                  groupValue: _itemType,
                  onChanged: changeItemType,
                )
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Regular'),
                trailing: new Radio<_ListType>(
                  value: _ListType.twoLine,
                  groupValue: _itemType,
                  onChanged: changeItemType,
                )
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Extra'),
                trailing: new Radio<_ListType>(
                  value: _ListType.threeLine,
                  groupValue: _itemType,
                  onChanged: changeItemType,
                ),
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Show avatar'),
                trailing: new Checkbox(
                  value: _showAvatars,
                  onChanged: (bool value) {
                    setState(() {
                      _showAvatars = value;
                    });
                    _bottomSheet?.setState(() { });
                  },
                ),
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Show icon'),
                trailing: new Checkbox(
                  value: _showIcons,
                  onChanged: (bool value) {
                    setState(() {
                      _showIcons = value;
                    });
                    _bottomSheet?.setState(() { });
                  },
                ),
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Show dividers'),
                trailing: new Checkbox(
                  value: _showDividers,
                  onChanged: (bool value) {
                    setState(() {
                      _showDividers = value;
                    });
                    _bottomSheet?.setState(() { });
                  },
                ),
              ),
            ),
            new MergeSemantics(
              child: new ListTile(
                dense: true,
                title: const Text('Dense layout'),
                trailing: new Checkbox(
                  value: _dense,
                  onChanged: (bool value) {
                    setState(() {
                      _dense = value;
                    });
                    _bottomSheet?.setState(() { });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });

    setState(() {
      _bottomSheet = bottomSheet;
    });

    _bottomSheet.closed.whenComplete(() {
      if (mounted) {
        setState(() {
          _bottomSheet = null;
        });
      }
    });
  }

  Widget buildListTile(BuildContext context, EMSTask item) {
    return new MergeSemantics(
      child: new ListTile(
        isThreeLine: _itemType == _ListType.threeLine,
        dense: _dense,
        leading: _showAvatars ? new ExcludeSemantics(child: new CircleAvatar(child: new Text(item.initials))) : null,
        title: new Text(item.title),
        subtitle: new Text(item.description),
        trailing: _showIcons ? new Icon(Icons.info, color: Theme.of(context).disabledColor) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String layoutText = _dense ? ' \u2013 Dense' : '';
    String itemTypeText;
    switch (_itemType) {
      case _ListType.oneLine:
      case _ListType.oneLineWithAvatar:
        itemTypeText = 'Terse';
        break;
      case _ListType.twoLine:
        itemTypeText = 'Standard';
        break;
      case _ListType.threeLine:
        itemTypeText = 'Extra';
        break;
    }

    Iterable<Widget> listTiles = items.map((EMSTask item) => buildListTile(context, item));
    if (_showDividers)
      listTiles = ListTile.divideTiles(context: context, tiles: listTiles);

    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('EMS Logging\n$itemTypeText$layoutText'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Sort',
            onPressed: () {
              setState(() {
                _reverseSort = !_reverseSort;
                items.sort((EMSTask a, EMSTask b) => _reverseSort ? b.compareTo(a) : a.compareTo(b));
              });
            },
          ),
          new IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Show menu',
            onPressed: _bottomSheet == null ? _showConfigurationSheet : null,
          ),
        ],
      ),
      body: new Scrollbar(
        child: new ListView(
          padding: new EdgeInsets.symmetric(vertical: _dense ? 4.0 : 8.0),
          children: listTiles.toList(),
        ),
      ),
    );
  }
}
