import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:newsssie/category.dart';
import 'package:newsssie/model.dart';
import 'package:http/http.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  TextEditingController searchController = new TextEditingController();
  List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  List<NewsQueryModel> newsModelListCarousel = <NewsQueryModel>[];
  List<String> navBarItems = [
    "Top News",
    "India",
    "Finance",
    "Health",
    "Sports"
  ];
  bool isLoading = true;
  getNewsByQuery(String query)async {
    Map element;
    int i = 0;
    String url = "https://newsapi.org/v2/everything?q=$query&from=2024-12-30&sortBy=publishedAt&apiKey=5e756d527610412cbb388ff3f434d20f";
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      for (element in data["articles"]) {
        try {
          i++;
          NewsQueryModel newsQueryModel = new NewsQueryModel();
          newsQueryModel = NewsQueryModel.fromMap(element);
          newsModelList.add(newsQueryModel);
          setState(() {
            isLoading = false;
          });
          if (i == 5) {
            break;
          }
        }catch(e){print(e);};

    }});
  }


  getNewsofIndia() async {
    String url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=5e756d527610412cbb388ff3f434d20f";
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      data["articles"].forEach((element) {
        NewsQueryModel newsQueryModel = new NewsQueryModel();
        newsQueryModel = NewsQueryModel.fromMap(element);
        newsModelListCarousel.add(newsQueryModel);
        setState(() {
          isLoading = false;
        });

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsByQuery("sports");
    getNewsofIndia();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
        appBar: AppBar(
          backgroundColor: Colors.white10.withBlue(5000),
          title: Text("Newsie Bee"),titleTextStyle: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          // scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.grey,Colors.white,]),
                    borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if ((searchController.text).replaceAll(" ", "") == "") {
                          print("Blank search");
                        } else {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => Category(Query: searchController.text)));
                        }
                      },
                      child: Container(
                        child: Icon(
                          Icons.search,
                          color: Colors.blueAccent,
                        ),
                        margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {Navigator.push(context, MaterialPageRoute(builder: (context) => Category(Query: value)));

                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search Health",
                            hintStyle: TextStyle(color: Colors.black)),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: navBarItems.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>Category(Query: navBarItems[index])));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            navBarItems[index],
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: isLoading ? Container(height: 200 , child: Center(child: CircularProgressIndicator())): CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: newsModelListCarousel.map((instance) {
                      return Builder(
                        builder: (BuildContext context){
                          try
                        {
                          return Container(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(instance.newsImg,fit: BoxFit.fitHeight,width: double.infinity,),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(colors: [
                                        Colors.black.withOpacity(0),
                                        Colors.black
                                        ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter
                                        ),

                                      ),
                                    child:
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                            child: Text(
                                              instance.newsHead,style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                            ),
                                        )
                                  ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }catch(e){print(e); return Container();}
                      });
                    },
                  ).toList(),
                ) ,
              ),
              Container(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(

                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(15,15,0,0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Latest News",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.blue.shade100
                              ),
                            ),
                          ],
                        ),
                      ),
                      isLoading? Container(height: MediaQuery.of(context).size.height-450,child: Center(child: CircularProgressIndicator(),),) :
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: newsModelList.length,
                          itemBuilder: (context, index) {
                            try{
                            return Container(
                                margin:
                                    EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 5.0,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            newsModelList[index].newsImg,fit: BoxFit.fitHeight, height: 230,width: double.infinity,
                                          )
                                      ),

                                      Positioned(
                                          left: 0,
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black.withOpacity(0),
                                                      Colors.black
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter),
                                              ),
                                              padding: EdgeInsets.fromLTRB(15,15,15,8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    newsModelList[index].newsHead,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(newsModelList[index].newsDes.length> 50 ? "${newsModelList[index].newsDes.substring(0,55)}...." : newsModelList[index].newsDes ,style: TextStyle(color: Colors.white,fontSize: 12),)
                                                ],
                                              ),
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                            );
                            }catch(e){print(e);return Container();}
                          },),
                      Container(
                        padding: EdgeInsets.fromLTRB(0,10,0,5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> Category(Query: "technology")));
                                },
                                child: Text("Show More",style: TextStyle(color: Colors.white),),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }


}
