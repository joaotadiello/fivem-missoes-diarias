import { create } from 'zustand'
import StateGlobal from './dto/state'
import Actions from './dto/actions'

export const useGlobal = create<StateGlobal & Actions>()((set) => ({
    list: [],
    setList: (data: DailyList[]) => set({ list: data }),
}))