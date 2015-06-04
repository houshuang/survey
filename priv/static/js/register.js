find_data_selectors = function() {
  console.log("Recalculating suggestions")
  var data = {};
  $("form").serializeArray().map(function(x){data[x.name] = x.value;}); 

  steams = []
  if (data["f[steam.a]"]) { steams.push("S") }
  if (data["f[steam.b]"]) { steams.push("T") }
  if (data["f[steam.c]"]) { steams.push("E") }
  if (data["f[steam.d]"]) { steams.push("A") }
  if (data["f[steam.e]"]) { steams.push("M") }

  grades = []
  if (data["f[grade.a]"]) { grades.push("1-3") }
  if (data["f[grade.b]"]) { grades.push("4-6") }
  if (data["f[grade.c]"]) { grades.push("7-8") }
  if (data["f[grade.d]"]) { grades.push("9-12") }

  jsons = []
  for (steam in steams) {
    for (grade in grades) {
      if (Window.tags[grades[grade]]) {
      jsons.push(Window.tags[grades[grade]][steams[steam]])
    }}
  }

  jsonsres = []
  for (json in jsons) {
    if (jsons[json]) { jsonsres = jsonsres.concat(jsons[json]) } 
  }

  Window.ms.setData(jsonsres)
}

$('input').on('change', function() { find_data_selectors() })


