module NinjaBlocks
  class Rule < Base
    
    def list
      get('/rule')
    end

    def create(rule, json)
      # create rule
      post("/rule", json)
    end
    
    def fetch(rid)
      get("/rule/#{rid}")
    end
    
    def update(rid, json)
      # update a rule
      put("/rule/#{rid}")
    end
    
    def destroy(rid)
      # delete a rule
      delete("/rule/#{rid}")
    end
    
    def suspend(rid)
      # suspend a rule
      post("/rule/#{rid}/suspend")
    end
    
    def unsuspend(rid)
      # unsuspend a rule
      delete("/rule/#{rid}/suspend")
    end

  end
end


