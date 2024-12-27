package j24w;

import ec.Entity;
import ec.Component;
import j24w.FishyData;

class BuyingBilding extends Component {
    @:once var defs:BuildingsDef;
    @:once var state:FishyState;

    public function buy(slotId:Int, defId) {
        var slot = state.slots[slotId];
        var b = slot.building;
        var def:BuildingDef = defs.get(defId);
        var price = def.price[0];
        if (price > state.stats.buck.value)
            return false;

        state.stats.buck.value -= price;
        b.initBuilding(defId, 0);
        slot.value = Building(b);
        return true;
    }
    
    // public function canUpgrade(slotId) {
    //     var slot = state.slots[slotId];
    //     var b = slot.building;
    //     var curLvl = b.level;
    //     var defId = b.defId;
    //     var def:BuildingDef = defs.get(defId, lvl);
    //     return (def.curLvl < def.maxLvl && canBuyDef(def));
    // }
    
    // inline function canBuyDef(def:BuildingDef) {
    //     var price = def.price[lvl];
    //     return price < state.stats.buck.value;
    // }
    
    // public function canBuy(defIf, lvl) {
    //     var def:BuildingDef = defs.get(defId, lvl);
    //     return canBuyDef(def);

    //     // if (! def.curLvl < def.maxLvl)
    //     //     return false;

 
    
    // }
    
    
    public function demolish(slotId) {
        var slot = state.slots[slotId];
        var b = slot.building;
        b.demolish();
        slot.value = Empty;
    }
    
    public function upgrade(slotId) {
        var slot = state.slots[slotId];
        var b = slot.building;
        var curLvl = b.level;
        var defId = b.defId;
        var def:BuildingDef = defs.get(defId);
        var price = def.price[curLvl + 1];
        if (price > state.stats.buck.value)
            return false;

        state.stats.buck.value -= price;
        b.demolish();
        b.initBuilding(defId, curLvl +1);
        slot.value = Building(b);
        return true;
    }

}
