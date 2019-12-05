import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(title: "GQL App", home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(uri: "http://192.168.0.10:4000/");
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      ),
    );
    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String query = r"""
                    query{
                    users{
                      name
                    }
                }
                  """;

  final String queryContinent = r"""
                    query{
                      continents{
                        name
                        code
                        countries{
                          name
                        }
                      }
                    }
                  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GraphQL para Flutter'),
      ),
      body: Query(
        options: QueryOptions(documentNode: gql(query)),
        builder: (
          QueryResult result, {
          Refetch refetch,
          FetchMore fetchMore,
        }) {
          if (result.data == null) {
            return Text('No data found!!');
          }
          print(result.data);
          // print(result.data['continents'].toString());
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              print(result.data['users'][index]['name']);
              return ListTile(
                title: Text(result.data['users'][index]['name']),
              );
            },
            itemCount: result.data['users'].length,
          );
        },
      ),
    );
  }
}
