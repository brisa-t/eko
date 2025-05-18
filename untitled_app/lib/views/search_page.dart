import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/custom_widgets/pagination.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show SearchLoader;
import '../controllers/search_page_controller.dart';
import '../custom_widgets/searched_user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return prov.ChangeNotifierProvider(
      create: (context) => SearchPageController(context: context),
      builder: (context, child) {
        return  GestureDetector(
            onPanDown: (details) =>
                prov.Provider.of<SearchPageController>(context, listen: false)
                    .hideKeyboard(),
            onTap: () =>
                prov.Provider.of<SearchPageController>(context, listen: false)
                    .hideKeyboard(),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(height * 0.01),
                child: PaginationPage(
                  initialLoadingWidget: const SearchLoader(),
                  //forceLoadingState: true,
                  getter: prov.Provider.of<SearchPageController>(context,
                          listen: true)
                      .getter,
                  card: searchPageBuilder,
                  startAfterQuery: prov.Provider.of<SearchPageController>(
                          context,
                          listen: false)
                      .startAfterQuery,
                  header: TextField(
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(height * 0.01),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(width * 0.035),
                        child: Image.asset(
                            (Theme.of(context).brightness == Brightness.dark)
                                ? 'images/algolia_logo_white.png'
                                : 'images/algolia_logo_blue.png',
                            width: width * 0.05,
                            height: width * 0.05),
                      ),
                      hintText: AppLocalizations.of(context)!.search,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.outlineVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (s) => prov.Provider.of<SearchPageController>(
                            context,
                            listen: false)
                        .onSearchTextChanged(s),
                    controller: prov.Provider.of<SearchPageController>(context,
                            listen: false)
                        .searchTextController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
        );
      },
    );
  }
}