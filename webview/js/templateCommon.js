scaleW = document.documentElement.clientWidth / 320;
scaleH = document.documentElement.clientHeight / 480;
var resizes = document.querySelectorAll('.resize');
for (var j = 0; j < resizes.length; j++) {
    resizes[j].style.width = parseInt(resizes[j].style.width) * scaleW + 'px';
    resizes[j].style.height = parseInt(resizes[j].style.height) * scaleH + 'px';
    resizes[j].style.top = parseInt(resizes[j].style.top) * scaleH + 'px';
    resizes[j].style.left = parseInt(resizes[j].style.left) * scaleW + 'px';
}

//scaleW = window.innerWidth / 320;
//scaleH = window.innerHeight / 480;
//var resizes = document.querySelectorAll('.resize');
//for (var j = 0; j < resizes.length; j++) {
//    resizes[j].style.width = parseInt(resizes[j].style.width) * scaleW + 'px';
//    resizes[j].style.height = parseInt(resizes[j].style.height) * scaleH + 'px';
//    resizes[j].style.top = parseInt(resizes[j].style.top) * scaleH + 'px';
//    resizes[j].style.left = parseInt(resizes[j].style.left) * scaleW + 'px';
//}
var mySwiper = new Swiper(
                          '.swiper-container', {
                          direction: 'vertical',
                          //        pagination: '.swiper-pagination',
                          //        virtualTranslate : true,
                          mousewheelControl: true,
                          onInit: function (swiper) {
                         
                          swiperAnimateCache(swiper);
                          swiperAnimate(swiper);
                          
                          swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0].play();
                          document.getElementsByClassName("audioCtrl")[swiper.activeIndex].addEventListener("click", function () {
                                                                                                            var _ = swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0];
                                                                                                            if (_.paused == true) {
                                                                                                            _.play();
                                                                                                            } else {
                                                                                                            _.pause();
                                                                                                            }
                                                                                                            })
                          },
                          onSlideChangeEnd: function (swiper) {
                          
                          swiperAnimate(swiper);
                          document.getElementsByClassName("audioCtrl")[swiper.activeIndex].addEventListener("click", function () {
                                                                                                            var _ = swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0];
                                                                                                            if (_.paused == true) {
                                                                                                            _.play();
                                                                                                            } else {
                                                                                                            _.pause();
                                                                                                            }
                                                                                                            })
                          if (document.getElementsByTagName("audio").length > 0) {
                          for (var i = 0; i < document.getElementsByTagName("audio").length; i++) {
                          document.getElementsByTagName("audio")[i].currentTime = 0.0;
                          document.getElementsByTagName("audio")[i].pause();
                          }
                          }
                          setTimeout(function () {
                                     if (swiper.slides[swiper.activeIndex].getElementsByTagName("audio").length) {
                                     swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0].play();
                                     }
                                     }, 5)
                          },
                          onTransitionEnd: function (swiper) {
                          swiperAnimate(swiper);
                          document.getElementById("numOfPage").value = swiper.activeIndex;
                          
                          },
                          watchSlidesProgress: true,
                          onProgress: function (swiper) {
                          for (var i = 0; i < swiper.slides.length; i++) {
                          var slide = swiper.slides[i];
                          var progress = slide.progress;
                          var translate = progress * swiper.height / 4;
                          scale = 1 - Math.min(Math.abs(progress * 0.5), 1);
                          var opacity = 1 - Math.min(Math.abs(progress / 2), 0.5);
                          slide.style.opacity = opacity;
                          es = slide.style;
                          es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = 'translate3d(0,' + translate + 'px,-' + translate + 'px) scaleY(' + scale + ')';
                          }
                          },
                          onSetTransition: function (swiper, speed) {
                          for (var i = 0; i < swiper.slides.length; i++) {
                          es = swiper.slides[i].style;
                          es.webkitTransitionDuration = es.MsTransitionDuration = es.msTransitionDuration = es.MozTransitionDuration = es.OTransitionDuration = es.transitionDuration = speed + 'ms';
                          }
                          }
                          })

var initSwiper = function(pageNumber){
    mySwiper = null;
  
    var mySwiper = new Swiper(
                              '.swiper-container', {
                              direction: 'vertical',
                              //        pagination: '.swiper-pagination',
                              //        virtualTranslate : true,
                              mousewheelControl: true,
                              onInit: function (swiper) {
                              swiper.slideTo(pageNumber,0,false);
                              swiperAnimateCache(swiper);
                              swiperAnimate(swiper);
                              
                              swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0].play();
                              document.getElementsByClassName("audioCtrl")[swiper.activeIndex].addEventListener("click", function () {
                                                                                                                var _ = swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0];
                                                                                                                if (_.paused == true) {
                                                                                                                _.play();
                                                                                                                } else {
                                                                                                                _.pause();
                                                                                                                }
                                                                                                                })
                              },
                              onSlideChangeEnd: function (swiper) {
                              
                              swiperAnimate(swiper);
                              document.getElementsByClassName("audioCtrl")[swiper.activeIndex].addEventListener("click", function () {
                                                                                                                var _ = swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0];
                                                                                                                if (_.paused == true) {
                                                                                                                _.play();
                                                                                                                } else {
                                                                                                                _.pause();
                                                                                                                }
                                                                                                                })
                              if (document.getElementsByTagName("audio").length > 0) {
                              for (var i = 0; i < document.getElementsByTagName("audio").length; i++) {
                              document.getElementsByTagName("audio")[i].currentTime = 0.0;
                              document.getElementsByTagName("audio")[i].pause();
                              }
                              }
                              setTimeout(function () {
                                         if (swiper.slides[swiper.activeIndex].getElementsByTagName("audio").length) {
                                         swiper.slides[swiper.activeIndex].getElementsByTagName("audio")[0].play();
                                         }
                                         }, 5)
                              },
                              onTransitionEnd: function (swiper) {
                              swiperAnimate(swiper);
                              document.getElementById("numOfPage").value = swiper.activeIndex;
                              
                              },
                              watchSlidesProgress: true,
                              onProgress: function (swiper) {
                              for (var i = 0; i < swiper.slides.length; i++) {
                              var slide = swiper.slides[i];
                              var progress = slide.progress;
                              var translate = progress * swiper.height / 4;
                              scale = 1 - Math.min(Math.abs(progress * 0.5), 1);
                              var opacity = 1 - Math.min(Math.abs(progress / 2), 0.5);
                              slide.style.opacity = opacity;
                              es = slide.style;
                              es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = 'translate3d(0,' + translate + 'px,-' + translate + 'px) scaleY(' + scale + ')';
                              }
                              },
                              onSetTransition: function (swiper, speed) {
                              for (var i = 0; i < swiper.slides.length; i++) {
                              es = swiper.slides[i].style;
                              es.webkitTransitionDuration = es.MsTransitionDuration = es.msTransitionDuration = es.MozTransitionDuration = es.OTransitionDuration = es.transitionDuration = speed + 'ms';
                              }
                              }
                              })
}

