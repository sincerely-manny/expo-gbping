import GBPing, { PingStatus } from "expo-gbping";
import { useState } from "react";
import {
  ActivityIndicator,
  Button,
  SafeAreaView,
  ScrollView,
  Text,
  TextInput,
  View,
} from "react-native";

export default function App() {
  const [result, setResult] = useState<string | null>(null);
  const [pinging, setPinging] = useState(false);
  const [url, setUrl] = useState("google.com\nfacebook.com\n192.168.2.255");
  const [timeout, setTimeout] = useState<number | undefined>(undefined);

  const handlePing = async () => {
    setPinging(true);
    let newResult = "";
    const urls = url.split(`\n`);
    for (const u of urls) {
      try {
        const r = await GBPing.ping(u, timeout);
        newResult += `Ping successful: ${r}\n`;
      } catch (error) {
        console.error(error);
        newResult += `Ping failed: ${u}\n`;
      }
      setResult(newResult);
    }
    setPinging(false);
  };

  const handleStartPinging = async () => {
    setResult("");
    setPinging(true);
    const u = url.split(`\n`).pop();
    if (!u) {
      setPinging(false);
      return;
    }
    GBPing.startPinging({
      url: url.split(`\n`).pop() || "",
      timeout: timeout,
      interval: 1000,
      onPing: (event) => {
        console.log(JSON.stringify(event, null, 2));
        if (event.status === PingStatus.Success) {
          setResult((prev) => `${prev}\n✅ ${event.sequenceNumber}. ${event.host}: ${event.rtt?.toFixed(2)}ms `);
        } else {
          setResult((prev => `${prev}\n❌ ${event.error}`));
        }
      },
    });
  }

  const handleStopPinging = () => {
    setPinging(false);
    GBPing.stopPinging();
  }



  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>Module API Example</Text>
        <Group name="Async functions">
          <Text style={styles.label}>
            List of URLs to ping separated by new lines:
          </Text>
          <TextInput
            multiline
            placeholder="Enter URL"
            onChangeText={setUrl}
            defaultValue={url}
            style={styles.textinput}
          />
          <Text style={styles.label}>Enter a timeout in milliseconds:</Text>
          <TextInput
            placeholder="Enter timeout"
            onChangeText={(t) => setTimeout(parseInt(t, 10) || undefined)}
          />
          <Button title="pingAsync" onPress={handlePing} />
          <Button title="startPinging ✅" onPress={handleStartPinging} />
          <Button title="stopPinging ❌" onPress={handleStopPinging} />
        </Group>
        <Group name="Result">
          <Text>{result}</Text>
          {pinging && <ActivityIndicator />}
        </Group>
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = {
  header: {
    fontSize: 30,
    margin: 20,
  },
  groupHeader: {
    fontSize: 20,
    marginBottom: 20,
  },
  group: {
    margin: 20,
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: "#eee",
  },
  view: {
    flex: 1,
    height: 200,
  },
  textinput: {
    marginBottom: 10,
  },
  label: {
    fontSize: 16,
    fontWeight: "semibold" as "semibold",
  },
};
