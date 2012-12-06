class AddTaxonForeignKeyConstraintToWeeklySales < ActiveRecord::Migration
    def change
        execute <<-SQL
      ALTER TABLE spree_weekly_sales
        ADD CONSTRAINT fk_taxon_constraint
        FOREIGN KEY (parent_id)
        REFERENCES spree_taxons(id)
        SQL
    end
end
