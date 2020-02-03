import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(title: "GQL App", home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(uri: "http://192.168.15.23:4000/");
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

  final String queryBook = r"""
                    query MyQuery {
                      books {
                        author
                        title
                      }
                    }

                  """;

  final String createBook = r"""
                    mutation createBook($author: String!, $title: String!) {
                      createBook(author: $author, title: $title) {
                        author
                        title
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
        options: QueryOptions(documentNode: gql(queryBook)),
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
          return Column(
            children: <Widget>[
              Mutation(
                options: MutationOptions(
                  documentNode: gql(createBook), // this is the mutation string you just created
                  // you can update the cache based on results
                  update: (Cache cache, QueryResult result) {
                    return cache;
                  },
                  // or do something with the result.data on completion
                  onCompleted: (dynamic resultData) {
                    print(resultData);
                  },
                ),
                builder: (RunMutation runMutation,
                    QueryResult result,) {
                  return RaisedButton(
                    onPressed: () {
                      runMutation({"author": "Israel", "title": "ZZZZZZZZZZ"});
                    },
                    child: Text('Mutation'),
                  );
                },
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    print(result.data['books'][index]['title']);
                    return ListTile(
                      title: Text(result.data['books'][index]['title']),
                    );
                  },
                  itemCount: result.data['books'].length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
