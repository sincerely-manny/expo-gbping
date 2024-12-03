import GBPing from "expo-gbping";
import { useState } from "react";
import {
  ActivityIndicator,
  Button,
  SafeAreaView,
  ScrollView,
  Text,
  View,
} from "react-native";

export default function App() {
  const [result, setResult] = useState<string | null>(null);
  const [pinging, setPinging] = useState(false);

  const handlePing = async () => {
    setPinging(true);
    try {
      const r = await GBPing.ping("google.com").catch((e) => console.error(e));
      setResult("Ping successful: " + r);
    } catch (error) {
      setResult("Ping failed: " + JSON.stringify(error));
    }
    setPinging(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>Module API Example</Text>
        <Group name="Async functions">
          <Button title="pingAsync" onPress={handlePing} />
        </Group>
        <Group name="Result">
          <Text>
            {pinging && <ActivityIndicator />} {result}
          </Text>
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
};
