import .fol tactic.tidy

open fol

local attribute [instance, priority 0] classical.prop_decidable
--local attribute [instance] classical.prop_decidable

local notation h :: t  := dvector.cons h t
local notation `[]` := dvector.nil
local notation `[` l:(foldr `, ` (h t, dvector.cons h t) dvector.nil `]`) := l

namespace peano
section

/-- Given a nat k and a 0-formula ψ, return ψ with ∀' applied k times to it --/ 
@[simp] def alls {L : Language}  :  Π n : ℕ, formula L → formula L
--:= nat.iterate all n
| 0 f := f
| (n+1) f := ∀' alls n f

@[simp]def bd_alls' {L : Language} : Π k n : ℕ, bounded_formula L (n + k) → bounded_formula L n
| 0 n         f := f
| (k+1) n     f := bd_alls' k n (∀' f)


@[simp]def bf_k_plus_zero {L} {k} : bounded_formula L (0 + k) = bounded_formula L k :=
by {convert rfl, rw[zero_add]}


@[simp] def bd_alls {L : Language}  : Π n : ℕ, bounded_formula L n → sentence L
| 0     f := f
| (n+1) f := bd_alls n (∀' f) -- bd_alls' (n+1) 0 (f.cast_eqr (zero_add (n+1)))

/-- generalization of bd_alls where we can apply less than n ∀'s--/


def bf_n_of_0_n {L : Language} {n} (ψ : bounded_formula L (0 + n)) : bounded_formula L n :=
by {convert ψ, rw[zero_add]}

def bf_0_n_of_n {L : Language} {n} (ψ : bounded_formula L n) : bounded_formula L (0 + n) :=
by {convert ψ, apply zero_add}

-- set_option pp.all true
-- set_option pp.notation false

@[simp]lemma mpr_lemma {α β: Type*} {p q : α = β} {x : β} : eq.mpr p x = eq.mpr q x := by refl

@[simp]lemma mpr_lemma2 {L} {n m : ℕ} {h : m = n} {h' : bounded_formula L m = bounded_formula L n} {h'' : bounded_formula L (m+1) = bounded_formula L (n+1)} {f : bounded_formula L (n+1)} : ∀' eq.mpr h'' f = eq.mpr h' (∀'f) :=
 by tidy

-- lemma obvious3 {L : Language} {n} {ψ : bounded_formula L (n+1)} (p q :  bounded_formula L (n - n) = bounded_formula L (n - n)) : eq.mpr p (bd_alls' n n (∀' ψ)) = eq.mpr q (bd_alls' n n (∀' ψ)) :=
-- by apply mpr_lemma -- refl also suffices here

-- lemma obvious4 {L : Language} {n} {ψ : bounded_formula L (n+1)} (p : bounded_formula L (n - n) = bounded_formula L (n - n)) :
-- (bd_alls' n n (∀' ψ)) = eq.mpr p (bd_alls' n n (∀' ψ)) :=
-- begin
--   have : bd_alls' n n (∀' ψ) = eq.mpr rfl (bd_alls' n n (∀' ψ)), by refl,
--   have := obvious3 rfl p, swap, exact ψ, cc
-- end
/- Obviously, bd_alls' n 0 ψ = bd_alls ψ -/
-- bd_alls n ψ = bd_alls' n 0 (by {convert ψ, apply zero_add})

--protected def cast_eqr {n m l} (h : n = m) (f : bounded_preformula L m l) : bounded_preformula L n l :=
--f.cast $ ge_of_eq h


@[simp] lemma alls'_alls {L : Language} : Π n (ψ : bounded_formula L n), bd_alls n ψ = bd_alls' n 0 (ψ.cast_eq (zero_add n).symm) :=
  by {intros n ψ, induction n, swap, simp[n_ih (∀' ψ)], tidy}

-- @[simp] lemma alls'_alls {L : Language} : Π n (ψ : bounded_formula L n), bd_alls n ψ = bd_alls' n 0 (by {convert ψ, apply zero_add}) :=
-- begin
--   intros n ψ, induction n with n ih generalizing ψ, refl, simp[ih (∀' ψ)]
-- end

@[simp]lemma alls'_all_commute {L : Language} {n} {k} {f : bounded_formula L (n+k+1)} : (bd_alls' k n (∀' f)) = ∀' bd_alls' k (n+1) (f.cast_eq (by simp))-- by {refine ∀' bd_alls' k (n+1) _, simp, exact f}
:=
  by {induction k; dsimp only [bounded_preformula.cast_eq], swap, simp[@k_ih (∀'f)], tidy}

-- @[simp]lemma alls'_all_commute {L : Language} {n} {k} {f : bounded_formula L (n + k + 1)} : bd_alls' k n (∀' f) = ∀' bd_alls' k (n+1) (by {simp, exact f}) :=
-- begin
--   induction k, refl, unfold bd_alls', rw[@k_ih (∀' f),<-mpr_lemma2],
--   simp only [add_comm, eq_self_iff_true, add_right_inj, add_left_comm]
-- end 



@[simp]lemma bd_alls'_substmax {L} {n} {f : bounded_formula L (n+1)} {t : closed_term L} : (bd_alls' n 1 (f.cast_eq (by simp)))[t /0] = (bd_alls' n 0 (substmax_bounded_formula (f.cast_eq (by simp)) t)) := by {induction n, {tidy}, have := @n_ih (∀' f), simp[bounded_preformula.cast_eq] at *, exact this}


lemma realize_sentence_bd_alls {L} {n} {f : bounded_formula L n} {S : Structure L} : S ⊨ (bd_alls n f) ↔ (∀ xs : dvector S n, realize_bounded_formula xs f []) :=
begin
  induction n,
    {tidy, convert a, apply dvector.zero_eq},
    {have := @n_ih (∀' f), simp[alls'_alls, alls'_all_commute] at this,
     cases this with this_mp this_mpr, split,
     intros H xs, cases xs, apply this_mp (by {convert H, tidy}),
     intro H, convert this_mpr (by {intros xs x, exact H (x :: xs)}), tidy}
end

@[simp] lemma alls_0 {L : Language} (ψ : formula L) : alls 0 ψ = ψ := by refl

--lemma bd_alls_all_commute {L : Language} : Π n (f : bounded_formula L (n+1)), bd_alls n (∀'f) = ∀' (bd_alls n (f))

-- @[simp] def b_alls_1 {L : Language} {n : ℕ} {f : formula L} (hf :  formula_below (n+1) f)  : formula_below n $ alls 1 f := begin
-- constructor, assumption
-- end

@[simp] lemma alls_all_commute {L : Language} (f : formula L) {k : ℕ} : (alls k ∀' f) = (∀' alls k f) := by {induction k, refl, dunfold alls, rw[k_ih]}



@[simp] lemma alls_succ_k {L : Language} (f : formula L) {k : ℕ} : alls (k + 1) f = ∀' alls k f := by constructor

-- @[simp] def b_alls_k {L : Language} {n : ℕ} {k: ℕ} :  ∀ f : formula L, formula_below (n + k) f → formula_below n (alls k f) :=
-- begin
--   induction k with k ih,
--   intros f hf, exact hf,
--   intros f hf, 
--   have H := alls_succ_k,

--   have hf_rw : formula_below (n + nat.succ k) f → formula_below (n+k) ∀'f, by {apply b_alls_1},
--   let hf2 := hf_rw hf,

--   have hooray := ih (∀'f) hf2,
--   rw[alls_all_commute, <-H] at hooray, exact hooray --hooray!!
-- end

/- both b_subst and b_subst2 are consequences of formula_below_subst in fol.lean -/
-- def b_subst {L : Language} {n : ℕ} {f : formula L} (hf : formula_below (n+1) f) {t : term L} (ht : term_below 0 t) : formula_below n (f[t //0]) :=
-- begin
-- have P := @formula_below_subst L 0 n 0 f begin rw[zero_add], exact hf end t,
-- have t' : term_below n t,
--   fapply term_below_of_le,
--   exact 0,
--   exact n.zero_le,
--   exact ht,
-- have Q := P t',
-- simp only [fol.subst_formula, zero_add] at Q, assumption
-- end

-- def b_subst2 {L : Language} {n : ℕ} {f : formula L} (hf : formula_below n f) {t : term L} (ht : term_below n t) : formula_below n (f[t //0]) :=
-- begin
--   have P := @formula_below_subst L 0 n 0 f begin rw[zero_add], fapply formula_below_of_le, exact n, simpa end t,
--   have P' := P ht, simp only [fol.subst_formula, zero_add] at P', assumption
-- end


/- END LEMMAS -/

/- The language of PA -/
inductive peano_functions : ℕ → Type -- thanks Floris!
| zero : peano_functions 0
| succ : peano_functions 1
| plus : peano_functions 2
| mult : peano_functions 2

def L_peano : Language := ⟨peano_functions, λ n, empty⟩

def L_peano_plus {n} (t₁ t₂ : bounded_term L_peano n) : bounded_term L_peano n := 
@bounded_term_of_function L_peano 2 n peano_functions.plus t₁ t₂
def L_peano_mult {n} (t₁ t₂ : bounded_term L_peano n) : bounded_term L_peano n := 
@bounded_term_of_function L_peano 2 n peano_functions.mult t₁ t₂

local infix ` +' `:100 := L_peano_plus
local infix ` ×' `:150 := L_peano_mult

def succ {n} : bounded_term L_peano n → bounded_term L_peano n := 
@bounded_term_of_function L_peano 1 n peano_functions.succ
def zero {n} : bounded_term L_peano n := bd_const peano_functions.zero
def one {n} : bounded_term L_peano n := succ zero

/- For each k : ℕ, return the bounded_term of L_peano corresponding to k-/
@[reducible]def formal_nat {n}: Π k : ℕ, bounded_term L_peano n
| 0 := zero
| (k+1) := succ $ formal_nat k

/- for all x, zero not equal to succ x -/
def p_zero_not_succ : sentence L_peano :=
∀'(zero ≃ succ &0 ⟹ ⊥)

@[reducible]def shallow_zero_not_succ : Prop :=
∀ n : ℕ, 0 = nat.succ n → false

def p_succ_inj : sentence L_peano := ∀' ∀'(succ &1 ≃ succ &0 ⟹ &1 ≃ &0)

@[reducible]def shallow_succ_inj : Prop := ∀ x, ∀ y, nat.succ x = nat.succ y → x = y

def p_zero_is_identity : sentence L_peano := ∀'(&0 +' zero ≃ &0)

@[reducible]def shallow_zero_is_identity : Prop := ∀ x : ℕ, x + 0 = x

/- ∀ x ∀ y,  x + succ y = succ( x + y) -/
def p_succ_plus : sentence L_peano := ∀' ∀'(&1 +' succ &0 ≃ succ (&1 +' &0))

@[reducible]def shallow_succ_plus : Prop := ∀ x, ∀ y, x + nat.succ y = nat.succ(x + y)

/- ∀ x, x ⬝ 0 = 0 -/
def p_zero_of_times_zero : sentence L_peano := ∀'(&0 ×' zero ≃ zero)

@[reducible]def shallow_zero_of_times_zero : Prop := ∀ x : ℕ, x * 0 = 0 

/- ∀ x y, (x ⬝ succ y = (x ⬝ y) + x -/
def p_times_succ  : sentence L_peano := ∀' ∀' (&1 ×' succ &0 ≃ &1 ×' &0 +' &1)

@[reducible]def shallow_times_succ : Prop := ∀ x : ℕ, ∀ y : ℕ, x * (y + 1) = (x * y) + x

/- The induction schema instance at ψ is the following formula (up to the fixed ordering of variables given by the de Bruijn indexing):

letting k+1 be the number of free vars of ψ:

 (k ∀'s)[(ψ(...,0) ∧ ∀' (ψ → ψ(...,S(x)))) → ∀' ψ]
-/
def p_induction_schema {n : ℕ} (ψ : bounded_formula L_peano (n+1)) : sentence L_peano :=
bd_alls n (ψ[zero/0] ⊓ ∀' (ψ ⟹ (ψ ↑' 1 # 1)[succ &0/0]) ⟹ ∀' ψ)

@[reducible]def shallow_induction_schema : Π P : set ℕ, Prop := λ P, (P(0) ∧ ∀ x, P x → P (nat.succ x)) → ∀ x, P x

/- The theory of Peano arithmetic -/
def PA : Theory L_peano :=
{p_zero_not_succ, p_succ_inj, p_zero_is_identity, p_succ_plus, p_zero_of_times_zero, p_times_succ} ∪  ⋃ (n : ℕ), (λ(ψ : bounded_formula L_peano (n+1)), p_induction_schema ψ) '' set.univ

@[reducible]def shallow_PA : set Prop :=
{shallow_zero_not_succ, shallow_succ_inj, shallow_zero_is_identity, shallow_succ_plus, shallow_zero_of_times_zero, shallow_times_succ} ∪ (shallow_induction_schema '' (set.univ))

def is_even : bounded_formula L_peano 1 :=
∃' (&0 +' &0 ≃ &1)

def L_peano_structure_of_nat : Structure L_peano :=
begin
  refine ⟨ℕ, _, _⟩,
  {intros n F, induction F, exact λv, 0,
   {intro v, cases v, exact nat.succ v_x},
   {intro v, cases v, exact v_x + (v_xs.nth 0 $ by constructor)},
   {intro v, cases v, exact v_x * (v_xs.nth 0 $ by constructor)},},
  {intro v, intro R, cases R},
end

local notation `ℕ'` := L_peano_structure_of_nat

@[simp]lemma floris {L} {S : Structure L} : ↥S = S.carrier := by refl

example : ℕ' ⊨ p_zero_not_succ := begin
change ∀ x : ℕ', 0 = nat.succ x → false, intros x h, cases h end

@[simp]lemma zero_is_zero : @realize_bounded_term L_peano ℕ' 0 [] 0 zero [] = nat.zero := by refl
@[simp]lemma one_is_one : @realize_bounded_term L_peano ℕ' 0 [] 0 one [] = (nat.succ nat.zero)  := by refl

instance has_zero_sort_L_peano_structure_of_nat : has_zero ℕ' := ⟨nat.zero⟩

instance has_zero_L_peano_structure_of_nat : has_zero L_peano_structure_of_nat := ⟨nat.zero⟩

@[simp]lemma formal_nat_realize_term {n} : realize_closed_term ℕ' (formal_nat n) = n :=
  by {induction n, refl, tidy}

@[simp] lemma succ_realize_term {n} : realize_closed_term ℕ' (succ $ formal_nat n) = nat.succ n :=
begin
  dsimp[realize_closed_term, realize_bounded_term, succ, bounded_term_of_function],
  induction n, tidy
end

@[simp]lemma formal_nat_realize_formula {ψ : bounded_formula L_peano 1} (n) : realize_bounded_formula ([(n : ℕ')]) ψ [] ↔ ℕ' ⊨ ψ[(formal_nat n)/0] :=
begin
  induction n, all_goals{dsimp[formal_nat], simp[realize_subst_formula0]},
  have := @formal_nat_realize_term 0, unfold formal_nat at this, rw[this]
end

@[simp]lemma nat_bd_all {ψ : bounded_formula L_peano 1} : ℕ' ⊨ ∀'ψ ↔ ∀(n : ℕ'), ℕ' ⊨ ψ[(formal_nat n)/0] :=
begin
  refine ⟨by {intros H n, induction n, all_goals{dsimp[formal_nat], rw[realize_subst_formula0], tidy}}, _⟩,
  intros H n, have := H n, induction n, all_goals{simp only [formal_nat_realize_formula], exact this}
end

lemma shallow_induction (P : set nat) : (P(0) ∧ ∀ x, P x → P (nat.succ x)) → ∀ x, P x :=
  λ h, nat.rec h.1 h.2

-- @[simp]lemma subst0_subst0 {L} {n} {f : bounded_formula L (n+1)} {s₁} {s₂} : (f ↑' 1 # 1)[s₁ /0][s₂ /0] = f[s₁[s₂ /0] /0] := sorry -- this probably isn't true with careful lifting

-- @[simp]lemma subst_succ_is_apply {n} {k} : (succ &0)[formal_nat n /0] = @formal_nat k (nat.succ n) :=
-- begin
--   induction n, refl, symmetry, dsimp[formal_nat] at *, rw[<-n_ih],
--   unfold succ bounded_term_of_function formal_nat, tidy, induction n_n, tidy
-- end

-- @[simp]lemma subst_term'_cancel {n} {k} : Π ψ : bounded_formula L_peano (k + 1), (ψ ↑' 1 # 1)[succ &0 /0][formal_nat n /0] = ψ[formal_nat (nat.succ n) /0] := by simp
  
-- begin

--   -- intros n ψ, unfold subst0_bounded_formula, tidy, -- simp[lift_subst_formula_cancel ψ.fst 0],
--   -- sorry -- looks like here we need a lemma that generalizes lift_subst_formula_cancel to substitutions of terms, or something
-- end

---- oops, i think this is already somewhere in fol.lean
-- /-- Canonical extension of a dvector to a valuation --/
-- def val_of_dvector {α : Type*} [has_zero α] {n} (xs : dvector α n): ℕ' → α :=
-- begin
--   intro k,
--   by_cases nat.lt k n, 
--     exact xs.nth k h,
--     exact 0
-- end

-- @[reducible]def dvector.trunc {α : Type*} : ∀ {n m : nat} (h : n ≤ m) (xs : dvector α m), dvector α n
-- | 0 0 _ xs := []
-- | 0 (m+1) _ xs := []
-- | (n+1) 0 _ xs := by {exfalso, cases _x}
-- | (n+1) (m+1) h xs := begin cases xs, convert (xs_x::dvector.trunc _ xs_xs), tidy end

-- @[simp]lemma dvector_trunc_n_n {α : Type*} {n : nat} {h : n ≤ n} {v : dvector α n} : dvector.trunc h v = v := by {induction v, tidy}

-- @[simp]lemma dvector_trunc_0_n {α : Type*} {n : nat} {h : 0 ≤ n} {v : dvector α n} : dvector.trunc h v = [] := by {induction v, tidy}

/-- Given a term t with ≤ n free variables, the realization of t only depends on the nth initial segment of the realizing dvector v.  --/
-- lemma realize_closed_term_realize_irrel {L} {S : Structure L} {n n' : nat} {h : n' ≤ n} {t : bounded_term L n'} {v : dvector S n} : realize_bounded_term (dvector.trunc h v) t [] = realize_bounded_term v (t.cast h) [] :=
-- begin
--   revert t, apply bounded_term.rec, {intro k, induction k, induction v, have : n' = 0, by {apply nat.eq_zero_of_le_zero, exact h}, subst this, {tidy}, sorry},
--   tidy, sorry
-- end

-- lemma realize_closed_term_realizer_irrel {L} {S : Structure L} {n} {n'} {h : n' ≤ n} {t : bounded_term L n'} {v : dvector S n} : realize_bounded_term (@dvector.trunc n' n h xs) (t.cast (by simp)) [] = realize_bounded_term [] t [] :=
-- begin
--   induction n,
--      {cases v, revert t, },

--      {sorry},
-- end

-- lemma realize_bounded_formula_subst0_gen {L} {S : Structure L} {n l} (f : bounded_preformula L (n+1) l) {v : dvector S n} {xs : dvector S l} (t : bounded_term L n) : realize_bounded_formula v (f[(t.cast (by refl)) /0]) xs ↔ realize_bounded_formula ((realize_bounded_term v t [])::v) f xs :=
-- begin
--  sorry
-- end

-- realization of a substitution of a bounded_term (n' + 1) at n in a bounded_formula (n'' + 1), where n + n' = n'', is the same as realization (insert S[t])



lemma asjh {L} {S : Structure L} {n n' n''} {h : n + (n'+1) + 1 = n'' + 1} {t : bounded_term L (n'+1)} {f : bounded_formula L (n''+1)} {v : dvector S (n + n' + 1)} :
  @realize_bounded_formula L S n 0 v (@subst_bounded_formula L n (n' + 1) (n'' + 1) 0 f t (by assumption) = @realize_bounded_formula L S (n+1) 0 (dvector.insert (realize_bounded_term begin end t))

@[simp]lemma subst_falsum {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} : bd_falsum[t // n // h] = bd_falsum :=
  by tidy


-- #reduce (ℕ')[ ([] : dvector ℕ' 0) /// (@zero 0)]


-- #reduce (L_peano_structure_of_nat)[(p_zero_not_succ)]

-- #reduce (L_peano_structure_of_nat)[(&0 ≃ zero : bounded_formula L_peano 1) ;; ([0] : dvector (ℕ') 1)] 


@[simp]lemma subst0_falsum {L} {n} {t : bounded_term L n} : bd_falsum[t /0] = bd_falsum :=
  by {unfold subst0_bounded_formula, simpa only [subst_falsum]}

-- looks like here we additionally need substitution notation for bounded_term
@[simp]lemma subst_eq {L} {n n' n''} {h : n + n' + 1 = n''} {t₁ t₂ : bounded_term L n''} {t : bounded_term L n'} : (t₁ ≃ t₂)[t // n // h] = subst_bounded_term (t₁.cast_eq h.symm) t ≃ subst_bounded_term (t₂.cast_eq h.symm) t := by tidy -- TODO replace these with the fully expanded versions

@[simp]lemma subst0_eq {L} {n} {t : bounded_term L n} {t₁ t₂ : bounded_term L (n+1)} : (t₁ ≃ t₂)[t /0] = (t₁[t /0] ≃ t₂[t /0]) :=
  by {unfold subst0_bounded_formula, simpa only [subst_eq]}

@[simp]lemma subst_imp {L} {n n' n''} {h : n + n' + 1 = n''} {t : bounded_term L n'} {f₁ f₂ : bounded_formula L (n'')} : (f₁ ⟹ f₂)[t // n // h] = (f₁[t // n // h] ⟹ f₂[t // n // h]) := by tidy

@[simp]lemma subst0_imp {L} {n} {t : bounded_term L n} {f₁ f₂ : bounded_formula L (n+1)} : (f₁ ⟹ f₂)[t /0] = f₁[t /0] ⟹ f₂[t /0] :=
  by {unfold subst0_bounded_formula, simpa only [subst_imp]}

-- def hewwo : bounded_formula L_peano 1 := &0 ≃ zero

-- #reduce @realize_bounded_formula L_peano L_peano_structure_of_nat _ _ [] ((hewwo[ (succ zero) // 0 // (by simp)]).cast (by {refl})) [] -- sanity check, works as expected

#reduce @fol.subst_bounded_term L_peano 0 0 0 (&0) zero

-- #reduce (&0 : bounded_term L_peano 1)[zero // 0] -- elaborator fails, don't know why


-- this is the suspicious simp lemma--- don't want this
-- @[simp]lemma subst0_all {L} {n} {t : closed_term L} {f : bounded_formula L (n+2)} : (∀' f)[(t.cast (by simp)) /0] = begin apply bd_all, fapply subst_bounded_formula, exact n+2, exact f, exact (t.cast (by simp)), repeat{constructor} end :=
-- begin
--   sorry
-- end

@[simp]lemma subst_all {L} {n n' n''} {h : n + n' + 1 = n''} {t : closed_term L} {f : bounded_formula L (n'' + 1)} :
  (∀'f)[t.cast0 n' // n // (by {simp[h]})]
  = ∀'(f[(t.cast0 n' : bounded_term L n') // (n+1) // (by {tidy})]).cast_eq (by simp) :=
  by tidy

@[simp]lemma subst0_all {L} {n} {t : closed_term L} {f : bounded_formula L (n+2)} :
  ((∀'f)[t.cast (by simp) /0] : bounded_formula L n) = ∀'((f[t.cast0 n // 1 // (by {simp} : 1 + n + 1 = n + 2)]).cast_eq (by simp)) :=
  by tidy

-- {unfold subst0_bounded_formula, simp[@subst_all L n 0 (n+1) (by simp) t f], }


lemma zero_of_lt_one (n : nat) (h : n < 1) : n = 0 :=
  by {cases h, refl, cases nat.lt_of_succ_le h_a}

@[simp]lemma realize_bounded_term_subst0 {L} {S : Structure L} {n} (s : bounded_term L (n+1)) {v : dvector S n} (t : closed_term L) : realize_bounded_term v (s[(t.cast (by simp)) /0]) [] = realize_bounded_term ((realize_closed_term S t)::v) s [] :=
begin
revert s, refine bounded_term.rec1 _ _,
  {intro k, rcases k with ⟨k_val, k_H⟩, simp,
    induction n generalizing k_val, have := zero_of_lt_one k_val (by exact k_H), subst this,
    congr, {apply dvector.zero_eq}, {tidy}, cases nat.le_of_lt_succ k_H with H1 H2,
    swap, repeat{sorry}
    },
  {sorry}
end

-- intros, induction n, rw[dvector.zero_eq v],
--     {cases k, tidy,
--     have := zero_of_lt_one k_val (by exact k_is_lt), subst this,
--     congr, unfold subst0_bounded_term, tidy},
--     {
-- -- cases v, have := @n_ih v_xs, sorry
--     }

lemma subst0_bounded_formula_bd_apps_rel {L} {n l} (f : bounded_preformula L (n+1) l) 
  (t : closed_term L) (ts : dvector (bounded_term L (n+1)) l) :
  subst0_bounded_formula (bd_apps_rel f ts) (t.cast (by simp)) = 
  bd_apps_rel (subst0_bounded_formula f (t.cast (by simp))) (ts.map $ λt', subst0_bounded_term t' (t.cast (by simp))) :=
begin
  induction ts generalizing f, refl, simp[bd_apps_rel, ts_ih (bd_apprel f ts_x)], congr, tidy
end

lemma rel_subst0_irrel {L : Language} {n l} {R : L.relations l} {t : bounded_term L n} : (bd_rel R)[t /0] = (bd_rel R) := by tidy

-- lemma realize_bounded_formula_subst_insert {L} {S : Structure L} {n i} (f : bounded_formula L (n+1)) {v : dvector S n} (t : closed_term L) {h_i : i + 0 + 1 = n + 1}: realize_bounded_formula v (begin apply @subst_bounded_formula L i _ (n+1) _ f (by sorry), repeat{constructor} end) [] ↔ realize_bounded_formula (v.insert (realize_closed_term S t) i) f [] :=
-- begin
--   sorry
-- end

     -- maybe to finish this, need to generalize over all substitution indices---substitution at n corresponds to an insertion at n, and so on -- can finish by induction on vector length and use substmax
lemma realize_bounded_formula_subst0_gen {L} {S : Structure L} {n} {m} {m'} {h_m : m + m' + 1 = n+1} (f : bounded_formula L (n+1)) {v : dvector S n} (t : closed_term L) : realize_bounded_formula v ((f[t.cast (zero_le m') // m // h_m]).cast_eq (by {tidy})) [] ↔ realize_bounded_formula (dvector.insert (realize_closed_term S t) (m+1) v) f [] :=
begin
  revert n f v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {simp, intro a, cases a},
  {sorry}, -- this needs term version
  {sorry}, -- this needs version for bd_apps_rel
  {sorry},
  {simp[*, subst_all],}
end
set_option pp.implicit true
/-- realization of a subst0 is the realization with the substituted term prepended to the realizing vector --/
lemma realize_bounded_formula_subst0 {L} {S : Structure L} {n} (f : bounded_formula L (n+1)) {v : dvector S n} (t : closed_term L) : realize_bounded_formula v (f[(t.cast0 n) /0]) [] ↔ realize_bounded_formula ((realize_closed_term S t)::v) f [] :=
begin
  revert n f v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {simp},
  {simp},
  {rw[subst0_bounded_formula_bd_apps_rel], simp[realize_bounded_formula_bd_apps_rel, rel_subst0_irrel]},
  {simp*},
  {simp, apply forall_congr, clear ih, intro x, have := realize_bounded_formula_subst0_gen f t, tactic.rotate 1,
  exact S, exact 0, exact (n+1), {simp},
  exact (x::v), simp at this, rw[<-this],
  conv {to_lhs, congr, skip, congr, congr,
  skip, simp[closed_preterm.cast0]},
   apply iff_of_eq, congr' 2, simp,
  }
end

-- begin
-- dsimp[closed_term, closed_preterm] at t,
-- have := @realize_bounded_formula_subst0_gen L S n 0 f v [] (t.cast (by simp)),
-- unfold realize_closed_term, rw[<-realize_closed_term_realize_irrel] at this,
-- simp at this, split,
-- -- rest of this lemma relies on rewriting the bounded_preterm.cast t, after which simp[this] should work
-- {intro, apply this.mp, revert a, sorry},
-- {sorry},
-- end

lemma realize_bounded_formula_subst0' {L} {S : Structure L} {n} (f : bounded_formula L (n+1)) {v : dvector S n} (t : bounded_term L 1) (x : S) : realize_bounded_formula (x :: v) ((f ↑' 1 # 1)[(t.cast (by simp)) /0]) [] ↔ realize_bounded_formula ((realize_bounded_term ([x] : dvector S 1) t []) :: v) f [] := 
begin
revert f n v, refine bounded_formula.rec1 _ _ _ _ _; intros,
  {tidy},
  {sorry}, -- this requires a version of this lemma for terms
  {sorry}, -- same issue as the corresponding case above
  {sorry}, -- this one should be easy, just need a lemma about commutation with bd_imp
  {sorry}, -- same issues as the corresponding case above
end


/- ℕ' satisfies PA induction schema -/
theorem PA_standard_model_induction {index : nat} {ψ : bounded_formula L_peano (index + 1)} : ℕ' ⊨ bd_alls index (ψ[zero /0] ⊓ ∀'(ψ ⟹ (ψ ↑' 1 # 1)[succ &0 /0]) ⟹ ∀' ψ) :=
begin
  rw[realize_sentence_bd_alls], intro xs,
  simp,
  intros H_zero H_ih, apply nat.rec,
    {apply (realize_bounded_formula_subst0 ψ zero).mp, apply H_zero},
    {intros n H, apply (@realize_bounded_formula_subst0' _ _ _ ψ xs (succ &0) n).mp,
     exact H_ih n H}
end

def true_arithmetic := Th ℕ'

lemma true_arithmetic_extends_PA : PA ⊆ true_arithmetic :=
begin
  intros f hf, cases hf with not_induct induct,
  swap,
  {rcases induct with ⟨induction_schemas, ⟨⟨index, h_eq⟩, ih_right⟩⟩,
  rw[h_eq] at ih_right, simp[set.range, set.image] at ih_right,
  rcases ih_right with ⟨ψ, h_ψ⟩, subst h_ψ, apply PA_standard_model_induction},
  {repeat{cases not_induct}, tidy, contradiction}
end

lemma shallow_standard_model : ∀ ψ ∈ shallow_PA, ψ :=
begin
  intros x H, cases H,
    {repeat{cases H}, tidy, contradiction},
    {simp[shallow_induction_schema] at H, rcases H with ⟨y, Hy⟩, subst Hy, exact nat.rec}
end

def PA_standard_model : Model PA := ⟨ℕ', true_arithmetic_extends_PA⟩

end
end peano

