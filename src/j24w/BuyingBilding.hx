package j24w;

import ec.Entity;
import ec.Component;
import j24w.FishyData;

class BuyingBilding extends Component {
    @:once var defs:BuildingsDef;
    @:once var state:FishyState;

    public function buy(slotId:Int, defId) {
        var def = defs.getLvl(defId, 0);
        var b = new Building(new Entity(defId + "-" + slotId));
        for (a in def.actions)
            b.addAction(a);
        b.name = defId;
        entity.addChild(b.entity);
        state.slots[slotId].value = Building(b);
    }
}
