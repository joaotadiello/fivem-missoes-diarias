import { useEffect, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";
import Container from "./styled";
import { debugData } from "@/utils/debugData";
import { useGlobal } from "@/store/useGlobal";

debugData([
    {
        action: "setList",
        data: [
            { name: "Teste 1", available: true, id: "daily", objective: 10, current: 5 },
            { name: "Teste 2", available: false, id: "police", objective: 20, current: 10 },
        ] as DailyList[]
    }
])

const App = () => {
    const [visible, setVisible] = useState<boolean>(isEnvBrowser() ? true : false);
    const { list, setList } = useGlobal()

    useNuiEvent<boolean>('setVisible', setVisible)
    useNuiEvent<DailyList[]>('setList', setList)

    const handleClick = (missionId: string) => {
        fetchNui("mission:get:reward", missionId).then((data: DailyList[]) => {
            setList(data)
        })
    }

    useEffect(() => {
        if (!visible) return;
        const keyHandler = (e: KeyboardEvent) => {
            if (["Escape"].includes(e.code)) {
                fetchNui("hideFrame")
            }
        }

        window.addEventListener("keydown", keyHandler)

        return () => window.removeEventListener("keydown", keyHandler)
    }, [visible])

    return (
        <div className="nui" style={{
            display: visible ? "flex" : "none"
        }}>
            <Container>
                <h1>Missoes diarias</h1>
                {Object.values(list).map((item: DailyList, index: number) =>
                    <div key={index} className="w-[12.5em] h-auto flex flex-col justify-center items-center gap-2 bg-white/20">
                        <h2>{item.name}</h2>
                        <p>Available: {item.available ? "Yes" : "No"}</p>
                        <p>Objective: {item.available ? item.current + "/" + item.objective : "completed"}</p>
                        <div className="w-full h-1 bg-white/20 overflow-hidden">
                            <div className="h-full bg-white" style={{
                                width: `${(item.current / item.objective) * 100}%`
                            }} />
                        </div>
                        {item.available &&
                            <button
                                className="bg-teal-400 text-black rounded-sm"
                                onClick={() => handleClick(item.id)}
                            >
                                Resgatar
                            </button>
                        }
                    </div>
                )}
            </Container>
        </div>
    );
};

export default App;