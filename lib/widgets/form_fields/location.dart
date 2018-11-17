import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'dart:convert';
import '../../models/location_model.dart';

import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  Function setLocation;

  LocationInput(this.setLocation);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  LocationModel _locationModel;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressInputFocusNode.addListener(_updateLocation);
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address,
      'key': 'AIzaSyAq862bN5ChEtVqdSGxiw-8ClE47GGrSM4',
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    final coords = decodedResponse['results'][0]['geometry']['location'];
    _locationModel = LocationModel(
        address: formattedAddress,
        latitude: coords['lat'],
        longtitude: coords['lng']);

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyAq862bN5ChEtVqdSGxiw-8ClE47GGrSM4');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker('position', 'Position', _locationModel.latitude,
          _locationModel.longtitude),
    ],
        center: Location(_locationModel.latitude, _locationModel.longtitude),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
    widget.setLocation(_locationModel);
    setState(() {
      _addressInputController.text = _locationModel.address;
      _staticMapUri = staticMapUri;
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          validator: (String value) {
            if (_locationModel == null || value.isEmpty) {
              return 'Invalid Location';
            }
          },
          decoration: InputDecoration(labelText: 'Address'),
        ),
        SizedBox(
          height: 10.0,
        ),
        Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
