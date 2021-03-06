library revisions_controller;

import 'package:angular/angular.dart';
import 'dart:html';
import 'package:js/js.dart' as js;      // select2 is still in JavaScript
import 'dart:async';
import 'dart:js';
import 'package:angular/routing/module.dart';

import 'package:SecurityMonkey/service/revisions_service.dart';
import 'package:SecurityMonkey/routing/securitymonkey_router.dart' show param_from_url, param_to_url, map_from_url, map_to_url;


@Controller(
    selector: '[revisions]',
    publishAs: 'revisions_ctrl')
class RevisionsController {
  Router router;
  RouteProvider routeProvider;
  RevisionsService rs;

  Map<String, String> filter_params = {
    'filterregions': '',
    'filtertechnologies': '',
    'filteraccounts': '',
    'filternames': '',
    'filteractive': 'null',
    'searchconfig': null,
    'page': '1',
    'count': '25'
  };

  // Constructor
  RevisionsController(this.rs, this.router, this.routeProvider) { // this.bs
    js.context['getFilterString'] = getFilterString;
    js.context['pushFilterRoutes'] = pushFilterRoutes;
    this.current_result_type = this.routeProvider.route.parent.name;
    this.result_type_binded = current_result_type;
    print("ROUTE NAME: $current_result_type");
    if (routeProvider != null) {
      filter_params = map_from_url(filter_params, this.routeProvider);
      this.runbootstrap();
    }
  }

  void runbootstrap() {
    this.active_filter_value = this.filter_params['filteractive'];
    this.searchconfig = this.filter_params['searchconfig'];
    wasteASecond().then((_) {
      updateS2Tags(this.filter_params['filterregions'], 'regions');
      updateS2Tags(this.filter_params['filtertechnologies'], 'technologies');
      updateS2Tags(this.filter_params['filteraccounts'], 'accounts');
      updateS2Tags(this.filter_params['filternames'], 'names');
    });
  }

  void updateS2Tags(String filter, String id) {
    String s2id = '#s2_$id';
    String hidd = '#filter$id';
    if(filter != null && filter.length > 0) {
      filter = Uri.decodeComponent(filter);
      List<String> thelist = filter.split(',');
      var json = new JsObject.jsify(thelist);
      var select_box = js.context.jQuery(querySelector(s2id));
      select_box.select2("val", json);
      js.context.jQuery(querySelector(hidd)).val(select_box.val());
    }
  }

  // Let angular have a second to ng-repeat through all the select2 options
  Future wasteASecond() {
    return new Future.delayed(const Duration(milliseconds: 150), () => "1");
  }

  void pushFilterRoutes() {
    _add_param(filter_params, 'filterregions');
    _add_param(filter_params, 'filtertechnologies');
    _add_param(filter_params, 'filteraccounts');
    _add_param(filter_params, 'filternames');
    filter_params['filteractive'] = param_to_url(active_filter_value);
    filter_params['searchconfig'] = param_to_url(searchconfig);
    filter_params['page'] = '1';
    router.go(result_type_binded, filter_params);
  }

  void _add_param(Map<String, String> param_map, param_name) {
     String param_value = param_to_url(querySelector("#$param_name").attributes["value"]);
     param_map[param_name] = param_value;
  }

  // These two methods, getFilterString() and getParamString(..) are for select2.
  String getFilterString() {
    String regions = getParamString("filterregions", "regions");
    String technologies = getParamString("filtertechnologies", "technologies");
    String accounts = getParamString("filteraccounts", "accounts");
    String names = getParamString("filternames", "names");
    String active = this.active_filter_value != "null" ? "&active=$active_filter_value" : "";
    String retval = "&$regions&$technologies&$accounts&$names$active";
    print("getFilterString returning $retval");
    return retval;
  }

  String getParamString(String param_name, String param_url_name) {
    String param_value = querySelector("#$param_name").attributes["value"];
    if(param_value == null) {
      param_value = "";
    }
    return "$param_url_name=$param_value";
  }

  String active_filter_value = "null";
  String searchconfig = "";
  String current_result_type = "items";
  String result_type_binded = "items";

}
