//  Global.h
//  VideosChatDemo
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

//屏幕高度宏
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
//屏幕宽度宏
#define KScreenWidth [UIScreen mainScreen].bounds.size.width

#define template_1 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>     <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>        <section class='swiper-slide swiper-slide6'                 style='background: url(bg_2.jpg) no-repeat left top #7F1C7D'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='left:10px;top:50px; font-size: 30px; font-weight: bold; color: #fff;'                 swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                IBM Digital Sales            </div>            <div class='ani text_element resize'                 style='left:10px;top:90px; font-weight: bold; color: #fff;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Subtitle of presentation if needed            </div>            <div class='ani text_element resize'                 style='left:10px;top:380px; color: #fff;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Name of presenter, Title of presenter, Date of presentation in local format, Location of presentation            </div>            <img src='Picture1.png' class='ani img_element resize'                 style='height:15px; left:270px;top:460px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <img src='Picture2.png' class='ani img_element resize'                 style='height:10px; left:5px;top:465px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>        </section>    </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'></div><script src='templateUtils.js'></script></body></html>"

#define template_2 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>      <section class='swiper-slide swiper-slide7' style='background: #000'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='left:10px;top:50px; font-size: 24px; font-weight: bold; color: #7F1C7D;'                 swiper-animate-effect='slideInLeft'   swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Agenda            </div>            <ul class='ani resize'                style='left:30px;top:90px; color: #fff; padding-left: 10px;' swiper-animate-effect='slideInLeft'                swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                <li class='text_element' isList='true'>Agenda heading 1 Agenda content...... </li>                <li class='text_element' isList='true'>Agenda heading 1 Agenda content......                </li><li class='text_element' isList='true'>Agenda heading 1 Agenda content...... </li>            </ul>            <img src='Picture1.png' class='ani img_element resize'                 style='height:15px; left:270px;top:460px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <img src='Picture2.png' class='ani img_element resize'                 style='height:10px; left:5px;top:465px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>        </section>    </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>   </div> <script src='templateUtils.js'></script> </body></html>"

#define template_3 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>          <section class='swiper-slide swiper-slide8' style='background: #000'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='left:10px;top:50px; font-size: 24px; font-weight: bold; color: #7F1C7D;'                 swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'> Click to add title            </div>            <div class='ani text_element resize' style='left:10px;top:110px; width: 300px; color: #fff;' swiper-animate-effect='slideInLeft'   swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>  click to add content... click to add content... click to add content...            </div>            <img src='Picture1.png' class='ani img_element resize'                 style='height:15px; left:270px;top:460px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <img src='Picture2.png' class='ani img_element resize'                 style='height:10px; left:5px;top:465px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>        </section>   </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'></div> <script src='templateUtils.js'></script> </body></html>"

#define template_4 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>      <section class='swiper-slide swiper-slide9' style='background: #7F1C7D'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <img src='Picture1.png' class='ani img_element resize'                 style=' left:110px;top:219px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <div class='ani text_element resize'                 style='left:5px;top:465px; color: #fff; font-size: 10px;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                @2015 IBM Corporation            </div>        </section>     </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'></div> <script src='templateUtils.js'></script> </body></html>"

#define template_5 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>        <section class='swiper-slide swiper-slide9' style='background: #7F1C7D'>            <audio src=''></audio>            <img src='audio.png'  style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; ' class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='top:200px;z-index:1;font-size: 40px; color: white; text-align: center; width: 320px;'                 swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Thanks!            </div>            <div class='ani text_element resize'                 style='right:10px;top:400px; color: #fff;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Create by Carl            </div>            <div class='ani text_element resize'                 style='left:5px;top:465px; color: #fff; font-size: 10px;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                @2015 IBM Corporation            </div>        </section>    </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>   </div> <script src='templateUtils.js'></script> </body></html>"

#define template_6 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>     <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>     <section class='swiper-slide swiper-slide1'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='width: 310px; height:27px;left:10px;top:20px;z-index:2; font-weight: bold; font-size: 28px; color: white'                 swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                IBM Design Thinking            </div>            <img src='bg1.jpg' class='ani img_element' style='height:300px;left:0px;top:0px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <div class='ani text_element'                 style=' width:310px; left:10px;top:310px;z-index:3;' swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                IBM Design Thinking is a framework for delivering great user experiences to our clients.            </div>            <img src='img5.jpg' class='ani img_element' style=' height:25px;right:10px;bottom:10px; z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>        </section>   </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>   </div> <script src='templateUtils.js'></script> </body></html>"


#define template_8 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>   <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>       <section class='swiper-slide swiper-slide2'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <img src='img1.jpg' class='ani img_element resize' id=''                 style=' height:200px;left:0px;top:0px;z-index:1; '                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>            <ul class='ani resize' style='left:10px;top:230px;z-index:3;' swiper-animate-effect='slideInLeft'                swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                <li class='text_element' isList='true'>Good design is good business.— Thomas Watson Jr., 1973                </li>                <li class='text_element' isList='true'>Good design is good business.— Thomas Watson Jr., 1973                </li>                <li class='text_element' isList='true'>Good design is good business.— Thomas Watson Jr., 1973                </li>            </ul>        </section>    </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>    </div> <script src='templateUtils.js'></script> </body></html>"

#define template_7 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/> <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script> </head><body><div class='swiper-container'>    <div class='swiper-wrapper'>        <section class='swiper-slide swiper-slide3'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <ul class='ani resize'                style='top:20px; left:10px; z-index:3;padding: 10px; width: 290px;'                swiper-animate-effect='slideInLeft'                swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                <li class='text_element' isList='true' style=' border-left: 3px solid #2c5f99;'>                    Good design is good business.— Thomas Watson Jr., 1973                </li>                <li class='text_element' isList='true' style=' border-left: 3px solid #2c5f99;'>                    Good design is good business.— Thomas Watson Jr., 1973                </li>                <li class='text_element' isList='true' style=' border-left: 3px solid #2c5f99;'>                    Good design is good business.— Thomas Watson Jr., 1973                </li>            </ul>            <img src='img6.jpg' class='ani img_element' style='height:150px; right:10px; bottom:30px; z-index:2;'                 swiper-animate-effect='slideInLeft' swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>        </section>   </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>   </div> <script src='templateUtils.js'></script> </body></html>"

#define template_9 @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>    <section class='swiper-slide swiper-slide5'                 style='background: url(bg.jpg) no-repeat bottom right #00c5f2; background-size: 300px 300px;'>            <audio src=''></audio>            <img src='audio.png'                   style='width:30px;height:30px; top:10px; right:10px; position: absolute; z-index: 999; '                 class='audioCtrl showAudio'>            <div class='ani text_element resize'                 style='top:200px;z-index:1;font-size: 40px; color: white; text-align: center; width: 320px;'                 swiper-animate-effect='slideInLeft'                 swiper-animate-duration='0.3s' swiper-animate-delay='0.1s'>                Thanks!            </div>        </section>   </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'> </div> <script src='templateUtils.js'></script> </body></html>"


#define final_html_befor_section @"<!DOCTYPE html><html><head>    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>    <title>Template</title>    <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0'/>    <link rel='stylesheet' href='swiper.min.css'>    <link rel='stylesheet' href='animate.min.css'>    <link rel='stylesheet' href='common.css'> <script src='swiper.min.js'></script>    <script src='swiper.animate.min.js'></script></head><body><div class='swiper-container'>    <div class='swiper-wrapper'>       "

#define final_html_after_section @"    </div>    <img src='arrow.png' style='width:20px;height:15px; top:450px; left:160px; margin-left: -10px;' id='array' class='resize'>   </div> <script src='templateUtils.js'></script><script src='templateCommon.js'></script></body></html>"