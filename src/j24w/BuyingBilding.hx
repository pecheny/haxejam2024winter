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
        b.initBuilding(defId, 0);
        slot.value = Building(b);
    }
    
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
        b.demolish();
        b.initBuilding(defId, curLvl +1);
        slot.value = Building(b);
    }

}
