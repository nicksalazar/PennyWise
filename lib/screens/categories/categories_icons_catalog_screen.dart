import 'package:flutter/material.dart';

class IconsCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Catalog'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //finances
            _buildIconSection('Finances', [
              Icons.account_balance,
              Icons.account_balance_wallet,
              Icons.attach_money,
              Icons.money,
              Icons.money_off,
              Icons.monetization_on,
              Icons.payment,
              Icons.receipt,
              Icons.shopping_cart,
              Icons.shopping_bag,
              Icons.shopping_basket,
              Icons.shopping_cart,
              Icons.wallet_giftcard,
              Icons.wallet_membership,
              Icons.wallet_travel,
            ]),
            _buildIconSection('Transport', [
              Icons.airplanemode_active,
              Icons.airport_shuttle,
              Icons.directions_bus,
              Icons.directions_car,
              Icons.directions_boat,
              Icons.directions_bike,
              Icons.directions_walk,
              Icons.electric_bike,
              Icons.electric_car,
              Icons.local_taxi,
              Icons.train,
              Icons.tram,
            ]),
            _buildIconSection('Health', [
              Icons.favorite,
              Icons.favorite_border,
              Icons.healing,
              Icons.local_hospital,
              Icons.local_pharmacy,
              Icons.local_hotel,
              Icons.local_laundry_service,
              Icons.local_florist,
              Icons.local_gas_station,
              Icons.local_grocery_store,
              Icons.local_mall,
              Icons.local_movies,
              Icons.local_offer,
              Icons.local_parking,
              Icons.local_play,
              Icons.local_see
            ]),
            _buildIconSection('Education', [
              Icons.book,
              Icons.bookmark,
              Icons.bookmark_border,
              Icons.library_books,
              Icons.library_add,
              Icons.library_add_check,
              Icons.library_books,
              Icons.library_music,
              Icons.library_music_outlined,
              Icons.library_add_check,
              Icons.library_books,
              Icons.library_music,
              Icons.library_music_outlined,
              Icons.local_library,
            ]),
            _buildIconSection('Work', [
              Icons.work,
              Icons.work_off,
              Icons.work_outline,
              Icons.workspaces_filled,
              Icons.workspaces_outline,
              Icons.workspaces_rounded,
              Icons.workspaces_sharp,
              Icons.work_off_outlined,
              Icons.work_outline_outlined,
              Icons.work_off_sharp,
              Icons.work_outline_sharp,
            ]),
            //entertainment
            _buildIconSection('Entertainment', [
              Icons.art_track,
              Icons.av_timer,
              Icons.brush,
              Icons.camera,
              Icons.camera_alt,
              Icons.camera_front,
              Icons.camera_rear,
              Icons.camera_roll,
              Icons.collections,
            ]),

            //beauty
            

            _buildIconSection('Farm', [
              Icons.agriculture,
              Icons.fire_truck,
              Icons.local_shipping,
              Icons.grass,
            ]),
            _buildIconSection('Food and Drink', [
              Icons.local_drink,
              Icons.fastfood,
              Icons.restaurant,
              Icons.coffee,
              Icons.bakery_dining,
              Icons.local_bar,
              Icons.icecream,
              Icons.apple,
              Icons.food_bank,
              Icons.set_meal,
              Icons.local_pizza,
              Icons.cake,
              Icons.shopping_basket,
              Icons.cookie,
              Icons.local_cafe,
              Icons.wine_bar,
            ]),
            _buildIconSection('Home', [
              Icons.ac_unit,
              Icons.brush,
              Icons.house,
              Icons.chair,
            ]),
            _buildIconSection('Other', [
              Icons.cloud,
              Icons.info,
              Icons.help,
              Icons.star,
              Icons.church,
              Icons.emoji_events,
              Icons.brightness_2,
              Icons.change_history,
              Icons.settings,
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Acción al presionar el botón Select
        },
        label: Text('Select'),
      ),
    );
  }

  Widget _buildIconSection(String title, List<IconData> icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: icons.map((icon) => _buildIconItem(icon)).toList(),
        ),
      ],
    );
  }

  Widget _buildIconItem(IconData icon) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 30, color: Colors.black54),
    );
  }
}
