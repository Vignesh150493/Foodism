import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'dart:convert';
import '../../models/location_model.dart';
import '../../models/product.dart';
import 'package:location/location.dart' as geoloc;
import 'dart:async';

import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

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
    if (widget.product != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri =
          Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': 'AIzaSyAq862bN5ChEtVqdSGxiw-8ClE47GGrSM4',
      });
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];
      _locationModel = LocationModel(
          address: formattedAddress,
          latitude: coords['lat'],
          longtitude: coords['lng']);
    } else if (lat == null && lng == null) {
      _locationModel = widget.product.location;
    } else {
      _locationModel =
          LocationModel(address: address, latitude: lat, longtitude: lng);
    }

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
    if (mounted) {
      setState(() {
        _addressInputController.text = _locationModel.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  //Remember if we have async keyword, return value is wrapped into future.
  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${lat.toString()},${lng.toString()}',
      'key': 'AIzaSyAq862bN5ChEtVqdSGxiw-8ClE47GGrSM4',
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getCurrentLocation() async {
    final location = geoloc.Location();
    final currentLocation = await location.getLocation();
    final address = await _getAddress(
        currentLocation['latitude'], currentLocation['longitude']);
    _getStaticMap(address,
        geocode: false,
        lat: currentLocation['latitude'],
        lng: currentLocation['longitude']);
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
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
        FlatButton(
            onPressed: _getCurrentLocation,
            child: Text('Use Current location')),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
