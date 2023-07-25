import 'package:allen/feature_box.dart';
import 'package:allen/openai_service.dart';
import 'package:allen/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastwords='';
  final OpenAIService openAIService= OpenAIService();
  String? generatedContent;
  String? generatedImageURL;
  int start=200;
  int delay=200;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {
      
    });
  }

  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastwords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }


  @override
  void dispose(){
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInUp(child: const Text("Allen")),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          //virtualAssistant Picture
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration:const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //ChatBubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageURL==null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ).copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      generatedContent==null?"Good Morning, what can I do for you?":generatedContent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent==null?25:18,
                        fontFamily: 'Cera-Pro',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if(generatedImageURL!=null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(borderRadius: BorderRadius.circular(20) ,child:Image.network(generatedImageURL!),),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImageURL==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22,
                  ),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera-Pro',
                      color: Pallete.mainFontColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            //Suggestion List
            //features list
            Visibility(
              visible: generatedContent==null && generatedImageURL==null,
              child:  Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child:const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'Chat-GPT',
                      descriptionText:
                          'A smarter way to stay organised and informed with Chat-GPT 3.5O',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'A simple and smarter way to create creative images with Dall-E AI',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+2*delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E amd Chat-GPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start+3*delay),
        child: FloatingActionButton(
         backgroundColor: Pallete.firstSuggestionBoxColor,
         onPressed: () async {
           if(await speechToText.hasPermission && speechToText.isNotListening)
           {
             await startListening();
           }else if(speechToText.isListening)
            {
              final speech=await openAIService.isArtPromptAPI(lastwords);
              if(speech.contains('https')){
                generatedImageURL = speech;
                generatedContent = null;
                setState(() {
                  
                });
            
              }
              else{
                generatedImageURL = null;
                generatedContent = speech;
                setState(() {
                  
                });
                await systemSpeak(speech);
              }

              
              await stopListening();
            }
            else{
              initSpeechToText();
            }
         },
         child: Icon(speechToText.isListening?Icons.stop:Icons.mic,),),
      ),
    );
  }
}
