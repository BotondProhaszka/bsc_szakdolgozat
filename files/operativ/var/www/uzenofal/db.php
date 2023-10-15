<?php

/////////////////////////
// Configuration
/////////////////////////

// Master db for write operations
$master_db_host = '192.168.50.28';
$master_db_user = 'slave_241';
$master_db_past = 'H3rhMmQX0tQM';
$master_db_database = 'uzenofal';

// Slave db for read operations
$slave_db_host = 'localhost';
$slave_db_user = 'uzenofal';
$slave_db_past = 'H3rhMmQX0tQM';
$slave_db_database = 'uzenofal';


/////////////////////////
// Code
/////////////////////////
if (isset($_POST['message']) || isset($_POST['delete'])) {
	$conn = new mysqli($master_db_host, $master_db_user, $master_db_past, $master_db_database);
	// Check connection
	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}

	if (isset($_POST['message'])) {
		$stmt = $conn->prepare("INSERT INTO Messages (Sender, Message) VALUES (?, ?)");
		$stmt->bind_param("ss", $nev, $uzenet);

		// set parameters and execute
		$nev = $_POST['sender'];
		$uzenet = $_POST['message'];
		$stmt->execute();
	} else if (isset($_POST['delete'])) {
		$stmt = $conn->prepare("DELETE FROM Messages WHERE ID=?");
		$stmt->bind_param("i", $message_id);

		// set parameters and execute
		$message_id = $_POST['delete'];
		$stmt->execute();
	}
	$stmt->close();
	$conn->close();
	
	header('Location: /#read');
}


function show_messages() {
	// Create connection
	global $slave_db_host, $slave_db_user, $slave_db_past, $slave_db_database;
	$conn = new mysqli($slave_db_host, $slave_db_user, $slave_db_past, $slave_db_database);
	// Check connection
	if ($conn->connect_error) {
	  die("Connection failed: " . $conn->connect_error);
	}

	$sql = "SELECT ID, Sender, Message, Submitted FROM Messages order by ID desc";
	$result = $conn->query($sql);

	if ($result->num_rows > 0) {
	  // output data of each row
	  while($row = $result->fetch_assoc()) {
		echo "<p><b> " . $row["Submitted"]. " - " . $row["Sender"]. ":</b></p>";
		echo "<p> " . nl2br($row["Message"]) . "<p>";
		echo "<form method='post'><input type='hidden' name='delete' value='".$row['ID']."'><button class='btn btn-primary'>Üzenet törlése</button></from><br>";
	  }
	} else {
	  echo "Még nincs egy megjeleníthető üzenet sem.";
	}
	$conn->close();
	
}
