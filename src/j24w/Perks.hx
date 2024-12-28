package j24w;

import ec.PropertyComponent;
import j24w.FishyData.ItemsDef;
import ec.Component;
import j24w.FishyData;
import j24w.FishyState.AllStats;

class ItemsProperty extends PropertyComponent<Array<String>> {}

class Perks extends Component {
    public var values:Map<String, PerkableValue>;

    // @:once var state:FishyState;
    @:once var items:ItemsProperty;
    @:once var defs:ItemsDef;

    public function new(e) {
        super(e);
    }

    override function init() {
        super.init();
        items.onChange.listen(itemsChanged);
    }

    function itemsChanged() {
        values = new Map();
        for (iid in items.value)
            applyItem(iid);
    }
    
    public function addItem(itemId) {
        if (items.value.contains(itemId))
            throw "wrong";
        applyItem(itemId);
        items.value.push(itemId);
    }

    function applyItem(itemId) {
        var def = defs.get(itemId);
        var id = getPerkId(def.type, def.target);
        var pk = values.get(id);
        if (pk == null) {
            trace("pk set " + id);
            pk = new PerkableValue();
            values.set(id, pk);
        }
        pk.value += def.value;
    }

    function getPerkId(type:PerkType, target) {
        return type + "_" + target;
    }

    public function getCdmp(defId) {
        var pk = values.get(getPerkId(mp, defId));
        if (pk != null)
            return 1 - pk.getValue();
        return 1;
    }

    public function getResOutmp(resId) {
        var pk = values.get(getPerkId(mp, resId));
        if (pk != null)
            return 1 + pk.getValue();
        return 1;
    }

    public function getResOutadd(resId) {
        var pk = values.get(getPerkId(add, resId));
        if (pk != null)
            return pk.getValue();
        return 0;
    }
}

typedef ResPerkMap = Map<String, PerkableValue>;

class PerkableValue {
    public var value:Float = 0;

    public function new() {}

    public function getValue() {
        return value;
    }
}
