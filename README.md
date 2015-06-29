# Interactive components for INQ101: Teaching With Technology and Inquiry: An Open Course For Teachers

Starting June 12th, 2015, University of Toronto and University of Toronto Schools are offering a [MOOC on inquiry and technology for teachers](https://www.edx.org/course/teaching-technology-inquiry-open-course-university-torontox-inq101x). We want to experiment with interactivity and collaboration with an EdX MOOC, and are using LTI to embed external services. 

This is a Phoenix app which offers all the functionality we use. It will be continually updated as we add new features. The production server is deployed directly from this repo, so the code you see is always the most up-to-date. 

Hopefully a fairly large Phoenix app can be useful to others. Note that I am a beginner in both Elixir and Phoenix, and there might be a lot of code here that is not idiomatic, or uneccessarily verbose. 

I'm actively trying to isolate components that can be useful to others. So far, I have separated out [plug_lti](https://github.com/houshuang/plug_lti) and [param_session](https://github.com/houshuang/param_session), and might extract other components as we go along.

shaklev@gmail.com
