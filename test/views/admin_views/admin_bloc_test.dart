import 'package:crabpay/views/main_screen/_sub/admin_views/add_complete_product_and_field_data/bloc/admin_bloc.dart';
import 'package:crabpay/views/main_screen/_sub/admin_views/add_complete_product_and_field_data/bloc/admin_event.dart';
import 'package:crabpay/views/main_screen/_sub/admin_views/add_complete_product_and_field_data/bloc/admin_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminBloc', () {
    test('AdminEventSubmitsProduct stores the product', () async {
      final bloc = AdminBloc();
      addTearDown(bloc.close);
      final product = makeProduct();

      bloc.add(AdminEventSubmitsProduct(appProduct: product));
      await pumpEventQueue();

      expect(bloc.state.appProduct, product);
      expect(bloc.state.states, AdminStates.adminSubmitedAppProduct);
    });

    test('AdminEventSubmitsFields stores the fields', () async {
      final bloc = AdminBloc();
      addTearDown(bloc.close);
      final fields = [makeProductField(id: 'f1'), makeProductField(id: 'f2')];

      bloc.add(AdminEventSubmitsFields(appProductFields: fields));
      await pumpEventQueue();

      expect(bloc.state.appProductFields, fields);
      expect(bloc.state.states, AdminStates.adminSubmitedAppProductFields);
    });

    test('AdminEventPriceFillingDataIsPrepared sets the ready state', () async {
      final bloc = AdminBloc();
      addTearDown(bloc.close);

      bloc.add(AdminEventPriceFillingDataIsPrepared());
      await pumpEventQueue();

      expect(bloc.state.states, AdminStates.dataForSpaceFillingIsReady);
    });

    test('AdminEventSubmitsPriceImage stores the price image on the price fields', () async {
      final bloc = AdminBloc();
      addTearDown(bloc.close);
      final priceImage = {'1': 100.0, '2': 250.0};
      final imageField = makeProductField(id: 'f1', fieldName: 'Size', isPriceImage: true);
      final fieldsList = [imageField, makeProductField(id: 'f2')];

      bloc.add(AdminEventSubmitsPriceImage(priceImage: priceImage, imageField: imageField, fieldsList: fieldsList));
      await pumpEventQueue();

      expect(imageField.priceImages, priceImage);
      expect(bloc.state.appProductFields, fieldsList);
      expect(bloc.state.states, AdminStates.adminSubmitedPriceImage);
    });
  });
}
