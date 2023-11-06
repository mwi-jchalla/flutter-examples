// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = LayoutPage();
      case 3:
        page = TablePage();
      case 4:
        page = ListPage();
      case 5:
        page = ButtonsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.layers),
                        label: 'Layout',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.table_chart),
                        label: 'Tables',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'Lists',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.mouse),
                        label: 'Buttons',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.layers),
                        label: Text('Layout'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.table_chart),
                        label: Text('Tables'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.list),
                        label: Text('Lists'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.mouse),
                        label: Text('Buttons'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final mainContentColor =
        ColorScheme.fromSeed(seedColor: Colors.purpleAccent).surfaceVariant;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return ColoredBox(
      color: mainContentColor, // Use the main content color here
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Make Scaffold background transparent
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: HistoryListView(),
              ),
              SizedBox(height: 10),
              BigCard(pair: pair),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(icon),
                    label: Text('Like'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          // Make sure that the compound word wraps correctly when the window
          // is too narrow.
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final mainContentColor =
      ColorScheme.fromSeed(seedColor: Colors.purpleAccent).surfaceVariant;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ColoredBox(
      color: mainContentColor, // Use the main content color here
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Make Scaffold background transparent
        appBar: AppBar(title: Text("Favorites")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('You have '
                  '${appState.favorites.length} favorites:'),
            ),
            Expanded(
              // Make better use of wide windows with a grid.
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 400 / 80,
                ),
                children: [
                  for (var pair in appState.favorites)
                    ListTile(
                      leading: IconButton(
                        icon:
                            Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          appState.removeFavorite(pair);
                        },
                      ),
                      title: Text(
                        pair.asLowerCase,
                        semanticsLabel: pair.asPascalCase,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LayoutPage extends StatelessWidget {
  final mainContentColor =
      ColorScheme.fromSeed(seedColor: Colors.purpleAccent).surfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainContentColor,
      appBar: AppBar(title: Text("Layouts")),
      body: ListView(
        children: <Widget>[
          ListTile(
              title: Text("Row & Column"),
              onTap: () => _showRowAndColumn(context)),
          ListTile(title: Text("Stack"), onTap: () => _showStack(context)),
          ListTile(
              title: Text("Flow & Wrap"),
              onTap: () => _showFlowAndWrap(context)),
          ListTile(
              title: Text("Expanded & Flex"),
              onTap: () => _showExpandedAndFlex(context)),
          ListTile(
              title: Text("Align & Center"),
              onTap: () => _showAlignAndCenter(context)),
        ],
      ),
    );
  }

  _showRowAndColumn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Row & Column")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              // Using Row to position the columns next to each other
              children: [
                // First column
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 1 Child 1'),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 1 Child 2'),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: 8),
                            Text('Row Child 1'),
                            SizedBox(width: 8),
                            Text('Row Child 2'),
                            SizedBox(width: 8),
                            Text('Row Child 3'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16), // Spacing between the columns
                // Second column
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 2 Child 1'),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 2 Child 2'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16), // Spacing between the columns
                // Third column
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 3 Child 1'),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Column 3 Child 2'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showStack(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Stack")),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 100, height: 100, color: Colors.red),
              Container(width: 80, height: 80, color: Colors.green),
              Container(width: 60, height: 60, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  _showFlowAndWrap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Flow & Wrap")),
          body: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                List.generate(30, (index) => Chip(label: Text('Item $index')))
                    .toList(),
          ),
        ),
      ),
    );
  }

  _showExpandedAndFlex(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Expanded & Flex")),
          body: Column(
            children: [
              Expanded(flex: 2, child: Container(color: Colors.red)),
              Expanded(flex: 1, child: Container(color: Colors.green)),
              Expanded(flex: 3, child: Container(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  _showAlignAndCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Align & Center")),
          body: Container(
            width: 200,
            height: 200,
            color: Colors.amber,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(width: 50, height: 50, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}

class TablePage extends StatelessWidget {
  final mainContentColor =
      ColorScheme.fromSeed(seedColor: Colors.purpleAccent).surfaceVariant;
  final List<Employee> employees = [
    Employee(1, 'Alice', 'Manager', 55000.0),
    Employee(2, 'Bob', 'Developer', 45000.0),
    Employee(3, 'Charlie', 'Designer', 42000.0),
    Employee(4, 'David', 'Tester', 40000.0),
    Employee(5, 'Jane', 'Tester', 40000.0),
    Employee(6, 'Alex', 'Tester', 40000.0),
    Employee(7, 'Jessa', 'Developer', 45000.0),
    Employee(8, 'Mike', 'Developer', 45000.0),
    Employee(9, 'Justin', 'Manager', 55000.0),
    Employee(10, 'Chris', 'Developer', 45000.0),
    Employee(11, 'Zander', 'Developer', 45000.0),
    Employee(12, 'Kyle', 'Developer', 45000.0),
    Employee(13, 'Brendon', 'Developer', 45000.0),
    Employee(14, 'Bruce', 'Manager', 55000.0),
    Employee(15, 'Patricia', 'Tester', 40000.0),
    Employee(16, 'Mary', 'Tester', 40000.0),
    Employee(17, 'Octavia', 'Tester', 40000.0),
    Employee(18, 'Naomi', 'Developer', 45000.0),
    Employee(19, 'Sean', 'Developer', 45000.0),
    Employee(20, 'Josie', 'Tester', 40000.0),
    Employee(21, 'Jack', 'Tester', 40000.0),
    Employee(22, 'Rose', 'Developer', 45000.0),
    Employee(23, 'Nora', 'Manager', 55000.0),
    Employee(24, 'Danielle', 'Tester', 40000.0),
    Employee(25, 'Joey', 'Developer', 45000.0),
    Employee(26, 'Logan', 'Tester', 40000.0),
    Employee(27, 'Olivia', 'Developer', 45000.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainContentColor,
      appBar: AppBar(title: Text("Table Examples")),
      body: ListView(
        children: <Widget>[
          ListTile(
              title: Text("DataTable"), onTap: () => _showDataTable(context)),
          ListTile(
              title: Text("Simple Table"),
              onTap: () => _showSimpleTable(context)),
          ListTile(
              title: Text("Paginated DataTable"),
              onTap: () => _showPaginatedDataTable(context)),
        ],
      ),
    );
  }

  _showDataTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("DataTable")),
          body: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Position')),
                DataColumn(label: Text('Salary')),
              ],
              rows: employees
                  .map((employee) => DataRow(
                        cells: [
                          DataCell(Text(employee.id.toString())),
                          DataCell(Text(employee.name)),
                          DataCell(Text(employee.position)),
                          DataCell(Text(employee.salary.toStringAsFixed(2))),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  _showSimpleTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Simple Table")),
          body: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(),
              children: employees
                  .map((e) => TableRow(children: [
                        Text(e.id.toString()),
                        Text(e.name),
                        Text(e.position),
                        Text(e.salary.toStringAsFixed(2)),
                      ]))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  _showPaginatedDataTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Paginated DataTable")),
          body: SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text('Employees'),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Position')),
                DataColumn(label: Text('Salary')),
              ],
              source: _DataSource(employees),
              rowsPerPage: 5,
            ),
          ),
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Employee> _employees;
  int _selectedCount = 0;

  _DataSource(this._employees);

  @override
  DataRow getRow(int index) {
    final employee = _employees[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(employee.id.toString())),
        DataCell(Text(employee.name)),
        DataCell(Text(employee.position)),
        DataCell(Text(employee.salary.toStringAsFixed(2))),
      ],
    );
  }

  @override
  int get rowCount => _employees.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class Employee {
  final int id;
  final String name;
  final String position;
  final double salary;

  Employee(this.id, this.name, this.position, this.salary);
}

class ListPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<String> items = List.generate(50, (i) => "Item ${i + 1}");
  final mainContentColor =
      ColorScheme.fromSeed(seedColor: Colors.purpleAccent).surfaceVariant;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: mainContentColor, // Use the main content color here
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Make Scaffold background transparent
        appBar: AppBar(title: Text("List Examples")),
        body: ListView(
          children: <Widget>[
            ListTile(title: Text("Basic List"), onTap: () => _showBasicList()),
            ListTile(
                title: Text("Dynamic List"), onTap: () => _showDynamicList()),
            ListTile(
                title: Text("List with Separators"),
                onTap: () => _showListWithSeparators()),
            ListTile(title: Text("Grid List"), onTap: () => _showGridList()),
            // ... Add more list types as needed
          ],
        ),
      ),
    );
  }

  _showBasicList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Basic List")),
          body: ListView(
            children: items.map((item) => ListTile(title: Text(item))).toList(),
          ),
        ),
      ),
    );
  }

  _showDynamicList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Dynamic List")),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index]));
            },
          ),
        ),
      ),
    );
  }

  _showListWithSeparators() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("List with Separators")),
          body: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index]));
            },
          ),
        ),
      ),
    );
  }

  _showGridList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Grid List")),
          body: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(child: Center(child: Text(items[index])));
            },
          ),
        ),
      ),
    );
  }
}

class ButtonsPage extends StatelessWidget {
  const ButtonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buttons Showcase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buttonSection(
                'ElevatedButton',
                ElevatedButton(onPressed: () {}, child: Text('Normal')),
                ElevatedButton(onPressed: null, child: Text('Disabled'))),
            buttonSection(
                'TextButton',
                TextButton(onPressed: () {}, child: Text('Normal')),
                TextButton(onPressed: null, child: Text('Disabled'))),
            buttonSection(
                'OutlinedButton',
                OutlinedButton(onPressed: () {}, child: Text('Normal')),
                OutlinedButton(onPressed: null, child: Text('Disabled'))),
            iconButtonSection(
                'IconButton',
                IconButton(onPressed: () {}, icon: Icon(Icons.thumb_up)),
                IconButton(onPressed: null, icon: Icon(Icons.thumb_up))),
            // FloatingActionButton doesn't have a visibly distinct disabled state by default.
            // It typically uses a tooltip to indicate its action, which isn't displayed when disabled.
            buttonSection(
                'FloatingActionButton',
                FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
                FloatingActionButton(onPressed: null, child: Icon(Icons.add))),
          ],
        ),
      ),
    );
  }

  Widget buttonSection(String title, Widget normal, Widget disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        normal,
        SizedBox(height: 8),
        disabled,
        SizedBox(height: 16),
      ],
    );
  }

  Widget iconButtonSection(String title, Widget normal, Widget disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            normal,
            SizedBox(width: 16),
            disabled,
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
