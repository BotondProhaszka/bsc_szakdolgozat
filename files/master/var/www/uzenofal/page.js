const xValues = [];
const yValuesA = [];
const yValuesB = [];
let yMax = 4;
const connections = -1;

chartIt();
update();

async function chartIt(){
  await readData();
  new Chart("myChart", {
    type: "line",
    data: {
      labels: xValues,
      datasets: [{
        label: "Slaves",
        yAxisID: 'A',
	pointRadius: 5,
        pointBackgroundColor: "rgba(134,38,51, 0.95)",
        backgroundColor: ["rgba(134,38,51, 0.3)"],
        borderColor: "rgba(134,38,51, 1)",
        borderWidth: 1,
        data: yValuesA
      }, {
        label: "Connections",
        yAxisID: 'B',
	pointRadius: 5,
        pointBackgroundColor: "rgba(5,42,75, 0.95)",
        backgroundColor: ["rgba(5,42,75, 0.3)"],
        borderColor: "rgba(5,42,75, 1)",
        borderWidth: 1,
        data: yValuesB
      }]
    },
    options: {
      scales: {
	xAxes: [{
          display: true,
          scaleLabel: {
            display: true,
            labelString: 'Time'
          }
        }],
        yAxes: [{
         id: 'A', 
         ticks: {
            color: "rgba(134,38,51, 1)",
            min: 1,
            max: yMax,
            stepSize: 1
          },
	  position: 'left',
          scaleLabel: {
            display: true,
            labelString: 'Multiplicity',
            color: "rgba(134,38,51, 1)"
          }
	}, {
         id: 'B',
          ticks: {
            min: 1,
            max: yMax,
            stepSize: 1
          },
         position: 'right',
        }]
      },
      title: {
        display: true,
        text: 'Connections and running slaves'
      }
    }
  });
}



async function readData(){
  const response = await fetch('slaveDiagram.txt');
  const data = await response.text();
  const table = data.split('\n').slice(1);
  table.forEach(row => {
    if(row.length !==0){
      const columns = row.split('\t');
      console.log(row);
      const time = columns[0];
      xValues.push(time);
      const temp = columns[1];
      yValuesA.push(temp);
      if(yMax < temp)
        yMax = parseInt(temp);
      //console.log(time, temp);
    }
  });

  const response2 = await fetch('connDiagram.txt');
  const data2 = await response2.text();
  const table2 = data2.split('\n').slice(1);
  table2.forEach(row => {
    if(row.length !==0){
      const columns2 = row.split('\t');
      console.log(row);
      const temp2 = columns2[1];
      yValuesB.push(temp2);
      if(yMax < temp2)
        yMax = parseInt(temp2);
      console.log(temp2);
    }
  });
}


async function update(){
  readFiles();
  await setInterval;
  var timer = setInterval(async function() {
      await readFiles();
//      await readData();
 }, 5000);
}

async function readFiles(){
  const connResp = await fetch('connectionCount.txt');
  const conns = await connResp.text();
  document.getElementById("connections").innerText = conns;

  const slaResp = await fetch('slaveCount.txt');
  const slaves = await slaResp.text();
  document.getElementById("slaves").innerText = slaves;

  const slaIpResp = await fetch('ips.txt');
  const slaIP = await slaIpResp.text();
  document.getElementById("slavesIP").innerText = slaIP;

}
