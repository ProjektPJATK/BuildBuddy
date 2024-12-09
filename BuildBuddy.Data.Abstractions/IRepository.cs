using System.Linq.Expressions;

namespace BuildBuddy.Data.Abstractions;

public interface IRepository<TEntity, TId> where TEntity : class
{
    void Delete(TId id);
    void Delete(TEntity entityToDelete);
    Task<List<TEntity>> GetAsync(Expression<Func<TEntity, bool>> filter = null, Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null, string includeProperties = "");
    Task<List<TDto>> GetAsync<TDto>(Expression<Func<TEntity, TDto>> mapper, Expression<Func<TEntity, bool>> filter = null, Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null, string includeProperties = "");
    ValueTask<TEntity?> GetByID(TId id);
    Task<TEntity?> GetWithIncludesAsync<TInclude>(Expression<Func<TEntity, bool>> filter, Expression<Func<TEntity, TInclude>> include);
    Task<List<TDto>> GetRelatedEntitiesAsync<TJoinEntity, TDto>(Expression<Func<TJoinEntity, bool>> filter, Expression<Func<TJoinEntity, TDto>> mapper) where TJoinEntity : class, IHaveId<int> ;
    Task<List<TDto>> GetRelatedEntitiesAsync<TSource, TTarget, TDto>(Expression<Func<TSource, bool>> filterSource, Expression<Func<TSource, TTarget, bool>> relationCondition, Expression<Func<TSource, TDto>> mapper) where TSource : class where TTarget : class;
    Task<TDto?> GetByFieldAsync<TDto>(Expression<Func<TEntity, bool>> filter, Expression<Func<TEntity, TDto>> mapper);
    void Insert(TEntity entity);
    void Update(TEntity entityToUpdate);
}