import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/models/session.dart';
import 'package:new_field_visit_app/screens/session/all-sessions.dart';

class SingleSession extends StatefulWidget {
  Session singleSession;
  SingleSession({Session singleSession}) {
    this.singleSession = singleSession;
  }

  @override
  _SingleSessionState createState() => _SingleSessionState();
}

class _SingleSessionState extends State<SingleSession> {
  bool _isLoading = false;
  bool _is_saving = false;
  String _description;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      return Container(
          child: Scaffold(
        appBar: AppBar(
          title: Text(widget.singleSession.client),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Client Name',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          '${widget.singleSession.client}',
                        ),
                      ),
                    ],
                    rows: <DataRow>[
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Date')),
                          DataCell(Text(widget.singleSession.date)),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Start Time')),
                          DataCell(Text(widget.singleSession.start_time)),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('End Time')),
                          DataCell(Text(widget.singleSession.end_time)),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Purpose')),
                          DataCell(Text(widget.singleSession.purpose != null ? widget.singleSession.purpose : '')),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      autofocus: false,
                      minLines: 5,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.purpleAccent,
                      style: TextStyle(color: Colors.purpleAccent),
                      validator: (val) => val.isEmpty ? 'Description is required' : null,
                      initialValue: widget.singleSession.description,
                      onChanged: (val) {
                        setState(() => _description = val);
                      },
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.file_present,
                          color: Colors.purpleAccent,
                        ),
                        labelText: "Description of Visit",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          borderSide: new BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                    ),
                  ),
                )
              ]),
        ),
              bottomNavigationBar: BottomAppBar(
                child: InkWell(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Color(0xff4e54c8),
                              Color.fromRGBO(143, 148, 251, 1),
                            ]
                        )
                    ),
                    child: Center(
                      child: Text(
                        _is_saving ? "Please Wait..." : 'Update Session' ,
                        style: TextStyle(color: Colors.white, fontSize: 20),),
                    ),
                  ),
                  onTap: () async{
                    if(_formKey.currentState.validate()){
                      setState(() {
                        _isLoading = true;
                      });

                      var data = {
                        'description' : _description,
                        'id' : widget.singleSession.id
                      };
                      await UpdateSession(data);

                      //Navigator.push(
                      //  context,
                      //  new MaterialPageRoute(
                      //      builder: (context) => SessionRunning(
                      //
//
                      //      )
                      //  ),
                      //);
                    }
                  },
                ),
              )
      )
      );
    } else {
      return Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: SpinKitFadingCube(
            color: Color(0xff4e54c8),
            size: 40.0,
          ),
        ),
      );
    }
  }

  Future UpdateSession (data)async {
    await SessionApi().updateSession(data).then((value){

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
            context).showSnackBar(
          SnackBar(
            content: const Text(
                'Data Updated successfully'),
            backgroundColor: Colors
                .green,
            action: SnackBarAction(
              label: '☑',
              onPressed: () {},
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Sessions()
            ),
            ModalRoute.withName("/sessions")
        );
    });
  }
}
