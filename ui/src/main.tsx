// G:/dg-BattleRoyal/ui/src/main.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import Debug from "./pages/Debug";
import Notify from "./pages/Notify";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <Debug />
    <Notify />
  </React.StrictMode>
);
